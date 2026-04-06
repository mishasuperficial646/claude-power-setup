#!/usr/bin/env node
// Test: File list alignment between installer and uninstaller

"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert");
const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");

describe("File list alignment", () => {
  it("all source files exist that the installer references", () => {
    const expectedFiles = [
      "contexts/dev.md",
      "contexts/orchestrate.md",
      "contexts/review.md",
      "contexts/research.md",
      "reference/ORCHESTRATION-REFERENCE.md",
      "config/env-settings.json",
      "config/observer-config.json",
    ];

    for (const file of expectedFiles) {
      assert.ok(
        fs.existsSync(path.join(ROOT, file)),
        `Source file missing: ${file}`
      );
    }
  });

  it("all bin scripts exist", () => {
    const binDir = path.join(ROOT, "bin");
    const scripts = fs.readdirSync(binDir).filter((f) => f.endsWith(".sh"));
    assert.ok(scripts.length >= 3, `Expected ≥3 bin scripts, got ${scripts.length}`);
    assert.ok(scripts.includes("claude-aliases.sh"), "Missing claude-aliases.sh");
    assert.ok(scripts.includes("claude-loop.sh"), "Missing claude-loop.sh");
    assert.ok(scripts.includes("claude-session-save.sh"), "Missing claude-session-save.sh");
  });

  it("all instinct files exist", () => {
    const instinctsDir = path.join(ROOT, "instincts");
    const instincts = fs.readdirSync(instinctsDir).filter((f) => f.endsWith(".md"));
    assert.ok(instincts.length >= 4, `Expected ≥4 instincts, got ${instincts.length}`);
  });

  it("uninstaller references all files that the installer installs", () => {
    const uninstallSh = fs.readFileSync(path.join(ROOT, "uninstall.sh"), "utf8");
    const installSh = fs.readFileSync(path.join(ROOT, "install.sh"), "utf8");

    // Context profiles
    for (const ctx of ["dev.md", "orchestrate.md", "review.md", "research.md"]) {
      assert.ok(
        uninstallSh.includes(ctx),
        `Uninstaller missing reference to context: ${ctx}`
      );
    }

    // Reference doc
    assert.ok(
      uninstallSh.includes("ORCHESTRATION-REFERENCE.md"),
      "Uninstaller missing ORCHESTRATION-REFERENCE.md"
    );

    // Bin scripts
    for (const bin of ["claude-aliases.sh", "claude-loop.sh", "claude-session-save.sh"]) {
      assert.ok(
        uninstallSh.includes(bin),
        `Uninstaller missing reference to bin script: ${bin}`
      );
    }

    // Instincts
    const instinctsDir = path.join(ROOT, "instincts");
    const instincts = fs.readdirSync(instinctsDir).filter((f) => f.endsWith(".md"));
    for (const instinct of instincts) {
      assert.ok(
        uninstallSh.includes(instinct),
        `Uninstaller missing reference to instinct: ${instinct}`
      );
    }

    // Env settings keys
    const envSettings = JSON.parse(
      fs.readFileSync(path.join(ROOT, "config", "env-settings.json"), "utf8")
    );
    for (const key of Object.keys(envSettings)) {
      assert.ok(
        uninstallSh.includes(key),
        `Uninstaller missing env key: ${key}`
      );
    }
  });

  it("package.json 'files' includes all deployed directories", () => {
    const pkg = require(path.join(ROOT, "package.json"));
    const files = pkg.files || [];
    for (const required of ["cli.js", "contexts/", "bin/", "instincts/", "config/", "reference/"]) {
      assert.ok(
        files.includes(required),
        `package.json 'files' missing: ${required}`
      );
    }
  });
});
