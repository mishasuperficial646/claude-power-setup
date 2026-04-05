#!/usr/bin/env node
// Claude Power Setup — npm CLI installer
// Usage: npx claude-power-setup [--dry-run] [--force] [--skip-shell] [--skip-ecc]
//
// Delegates to install.sh if bash is available.
// Falls back to pure Node.js file operations on Windows without bash.

"use strict";

const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const os = require("os");

const SCRIPT_DIR = __dirname;
const CLAUDE_HOME = path.join(os.homedir(), ".claude");
const VERSION = "1.0.0";

const args = process.argv.slice(2);

if (args.includes("--help") || args.includes("-h")) {
  console.log(`
Claude Power Setup v${VERSION}
Multi-agent orchestration + self-improvement for Claude Code

Usage: npx claude-power-setup [OPTIONS]

Options:
  --dry-run      Show what would be installed without writing files
  --force        Overwrite existing files instead of skipping
  --skip-shell   Don't modify shell profile (.bashrc/.zshrc)
  --skip-ecc     Don't check for ECC installation
  --uninstall    Run the uninstaller instead
  --help         Show this help
`);
  process.exit(0);
}

// ── Try bash delegation ──────────────────────────────────────────
function findBash() {
  const candidates = [
    "/bin/bash",
    "/usr/bin/bash",
    "/usr/local/bin/bash",
    "C:\\Program Files\\Git\\bin\\bash.exe",
    "C:\\Program Files (x86)\\Git\\bin\\bash.exe",
  ];

  for (const candidate of candidates) {
    try {
      if (fs.existsSync(candidate)) return candidate;
    } catch {
      // skip
    }
  }

  // Try PATH
  try {
    execFileSync("bash", ["--version"], { stdio: "ignore" });
    return "bash";
  } catch {
    return null;
  }
}

const bashPath = findBash();

if (bashPath) {
  const script = args.includes("--uninstall")
    ? path.join(SCRIPT_DIR, "uninstall.sh")
    : path.join(SCRIPT_DIR, "install.sh");

  const bashArgs = args.filter((a) => a !== "--uninstall");

  try {
    execFileSync(bashPath, [script, ...bashArgs], {
      stdio: "inherit",
      env: { ...process.env, HOME: os.homedir() },
    });
  } catch (err) {
    process.exit(err.status || 1);
  }
  process.exit(0);
}

// ── Pure Node.js fallback (no bash available) ────────────────────
const DRY_RUN = args.includes("--dry-run");
const FORCE = args.includes("--force");

console.log(`
  Claude Power Setup v${VERSION}
  Multi-agent orchestration + self-improvement
  (Node.js native mode — bash not found)
`);

if (DRY_RUN) {
  console.log("[!] DRY RUN — no files will be written\n");
}

if (args.includes("--uninstall")) {
  console.log("[!] Uninstall requires bash. Please run:");
  console.log("    bash uninstall.sh");
  process.exit(1);
}

function safeCopy(src, dest, label) {
  if (DRY_RUN) {
    if (fs.existsSync(dest) && !FORCE) {
      console.log(`[i] SKIP (exists): ${label}`);
    } else {
      console.log(`[i] WOULD COPY: ${label} -> ${dest}`);
    }
    return;
  }

  const destDir = path.dirname(dest);
  fs.mkdirSync(destDir, { recursive: true });

  if (fs.existsSync(dest) && !FORCE) {
    console.log(`[i] Skip (exists): ${label}`);
    return;
  }

  fs.copyFileSync(src, dest);
  console.log(`[+] Installed: ${label}`);
}

// ── Context profiles ─────────────────────────────────────────────
console.log("Installing context profiles...");
for (const name of ["dev.md", "orchestrate.md", "review.md", "research.md"]) {
  safeCopy(
    path.join(SCRIPT_DIR, "contexts", name),
    path.join(CLAUDE_HOME, "contexts", name),
    `contexts/${name}`
  );
}

// ── Reference doc ────────────────────────────────────────────────
console.log("\nInstalling orchestration reference...");
safeCopy(
  path.join(SCRIPT_DIR, "reference", "ORCHESTRATION-REFERENCE.md"),
  path.join(CLAUDE_HOME, "contexts", "ORCHESTRATION-REFERENCE.md"),
  "reference/ORCHESTRATION-REFERENCE.md"
);

// ── Automation scripts ───────────────────────────────────────────
console.log("\nInstalling automation scripts...");
const binDir = path.join(SCRIPT_DIR, "bin");
for (const file of fs.readdirSync(binDir)) {
  if (file.endsWith(".sh")) {
    safeCopy(
      path.join(binDir, file),
      path.join(CLAUDE_HOME, "bin", file),
      `bin/${file}`
    );
    if (!DRY_RUN) {
      try {
        fs.chmodSync(path.join(CLAUDE_HOME, "bin", file), 0o755);
      } catch {
        // chmod may not work on Windows — that's fine
      }
    }
  }
}

// ── Instincts ────────────────────────────────────────────────────
console.log("\nInstalling learned instincts...");
const instinctDest = path.join(
  CLAUDE_HOME,
  "homunculus",
  "instincts",
  "personal"
);

if (!DRY_RUN) {
  for (const dir of [
    instinctDest,
    path.join(CLAUDE_HOME, "homunculus", "instincts", "inherited"),
    path.join(CLAUDE_HOME, "homunculus", "evolved", "agents"),
    path.join(CLAUDE_HOME, "homunculus", "evolved", "skills"),
    path.join(CLAUDE_HOME, "homunculus", "evolved", "commands"),
    path.join(CLAUDE_HOME, "session-data"),
    path.join(CLAUDE_HOME, "plans"),
  ]) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

const instinctsDir = path.join(SCRIPT_DIR, "instincts");
for (const file of fs.readdirSync(instinctsDir)) {
  if (file.endsWith(".md")) {
    safeCopy(
      path.join(instinctsDir, file),
      path.join(instinctDest, file),
      `instincts/${file}`
    );
  }
}

// ── Merge env settings ───────────────────────────────────────────
console.log("\nConfiguring settings.json...");
const settingsFile = path.join(CLAUDE_HOME, "settings.json");
const envFile = path.join(SCRIPT_DIR, "config", "env-settings.json");

if (!DRY_RUN && fs.existsSync(settingsFile) && fs.existsSync(envFile)) {
  try {
    const settings = JSON.parse(fs.readFileSync(settingsFile, "utf8"));
    const newEnv = JSON.parse(fs.readFileSync(envFile, "utf8"));

    if (!settings.env) settings.env = {};

    let added = 0;
    for (const [key, value] of Object.entries(newEnv)) {
      if (!(key in settings.env)) {
        settings.env[key] = value;
        added++;
        console.log(`[+] Added env: ${key}=${value}`);
      } else {
        console.log(`[i] Skip env (exists): ${key}=${settings.env[key]}`);
      }
    }

    if (added > 0) {
      fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + "\n");
    }
  } catch (err) {
    console.log(`[!] Could not merge env settings: ${err.message}`);
  }
} else if (DRY_RUN) {
  console.log(
    "[i] WOULD MERGE: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, ECC_HOOK_PROFILE, CLAUDE_CODE_ENABLE_COST_TRACKING"
  );
}

// ── Observer config ──────────────────────────────────────────────
console.log("\nConfiguring continuous learning observer...");
const observerSrc = path.join(SCRIPT_DIR, "config", "observer-config.json");
const clv2Config = path.join(
  CLAUDE_HOME,
  "skills",
  "continuous-learning-v2",
  "config.json"
);

if (fs.existsSync(clv2Config)) {
  if (DRY_RUN) {
    console.log(`[i] WOULD UPDATE: ${clv2Config} (observer.enabled=true)`);
  } else {
    fs.copyFileSync(observerSrc, clv2Config);
    console.log("[+] Observer enabled");
  }
} else {
  console.log("[!] CLv2 config not found — install ECC first for observer");
}

// ── Write marker ─────────────────────────────────────────────────
if (!DRY_RUN) {
  const marker = {
    version: VERSION,
    installed_at: new Date().toISOString(),
    platform: process.platform,
    installer: "npm",
    components: [
      "contexts",
      "bin-scripts",
      "instincts",
      "env-settings",
      "observer-config",
      "reference-doc",
    ],
  };
  fs.writeFileSync(
    path.join(CLAUDE_HOME, ".claude-power-setup-installed"),
    JSON.stringify(marker, null, 2) + "\n"
  );
}

// ── Summary ──────────────────────────────────────────────────────
console.log(`
  Installation Complete

  Next steps:
    1. source ~/.claude/bin/claude-aliases.sh  (or restart terminal)
    2. Open a project and run: claude
    3. Try: 'Please use a team of specialists for this'

  Reference: ~/.claude/contexts/ORCHESTRATION-REFERENCE.md
`);
