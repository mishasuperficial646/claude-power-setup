#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  Claude Power Setup — Portable Installer                    ║
# ║  Multi-agent orchestration, automation, and self-improvement║
# ║                                                             ║
# ║  Layers on top of ECC (Everything Claude Code).             ║
# ║  Works on: Windows (Git Bash), macOS, Linux                 ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

VERSION="1.0.1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"
MARKER_FILE="${CLAUDE_HOME}/.claude-power-setup-installed"

# ── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Anthropic brand palette (from anthropic.com CSS --heroes-accent)
C1='\033[38;2;217;119;87m'   # #D97757 — primary coral
C2='\033[38;2;232;149;106m'  # #E8956A — warm peach
C3='\033[38;2;245;184;154m'  # #F5B89A — light sand
C4='\033[38;2;250;249;240m'  # #FAF9F0 — Anthropic cream
C5='\033[38;2;201;104;66m'   # #C96842 — deep coral
C6='\033[38;2;184;90;45m'    # #B85A2D — burnt orange

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*"; }
info() { echo -e "${CYAN}[i]${NC} $*"; }
header() { echo -e "\n${BOLD}$*${NC}"; }

# ── Responsive Banner ────────────────────────────────────────
# Detects terminal width and renders appropriate banner size.
# Full block art ≥55 cols, styled text fallback for narrow terminals.
show_banner() {
  local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"

  if [ "$cols" -ge 55 ] 2>/dev/null; then
    # Full stacked: CLAUDE / POWER / SETUP — Anthropic coral gradient
    echo ""
    echo -e "${C1}  ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗${NC}"
    echo -e "${C1} ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝${NC}"
    echo -e "${C5} ██║     ██║     ███████║██║   ██║██║  ██║█████╗  ${NC}"
    echo -e "${C5} ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝  ${NC}"
    echo -e "${C6} ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗${NC}"
    echo -e "${C6}  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝${NC}"
    echo ""
    echo -e "${C2} ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ${NC}"
    echo -e "${C2} ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗${NC}"
    echo -e "${C1} ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝${NC}"
    echo -e "${C1} ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗${NC}"
    echo -e "${C5} ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║${NC}"
    echo -e "${C5} ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝${NC}"
    echo ""
    echo -e "${C3} ███████╗███████╗████████╗██╗   ██╗██████╗ ${NC}"
    echo -e "${C3} ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗${NC}"
    echo -e "${C2} ███████╗█████╗     ██║   ██║   ██║██████╔╝${NC}"
    echo -e "${C2} ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ ${NC}"
    echo -e "${C1} ███████║███████╗   ██║   ╚██████╔╝██║     ${NC}"
    echo -e "${C1} ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ${NC}"
  else
    # Styled text fallback for narrow terminals (<55 cols)
    echo ""
    echo -e "${C1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${C1}  ██${NC} ${BOLD}Claude${NC}"
    echo -e "${C5}  ██${NC} ${BOLD}Power${NC}"
    echo -e "${C6}  ██${NC} ${BOLD}Setup${NC}"
    echo -e "${C1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  fi

  echo ""
  echo -e "  ${CYAN}v${VERSION}${NC}  ${BOLD}Multi-agent orchestration + self-improvement${NC}"
  echo ""
}

# ── Responsive Summary ───────────────────────────────────────
show_summary() {
  local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"

  echo ""
  echo -e "${C1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  Installation Complete ${GREEN}✓${NC}"
  echo -e "${C1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${C1}Context Profiles${NC}"
  echo -e "    ${C2}cdev${NC}         Development mode (TDD, quality)"
  echo -e "    ${C2}corchestrate${NC} Team lead / swarm mode"
  echo -e "    ${C2}creview${NC}      Security-first code review"
  echo -e "    ${C2}cresearch${NC}    Read-only research mode"
  echo ""
  echo -e "  ${C1}Automation${NC}"
  echo -e "    ${C2}cpipeline${NC}    Implement → clean → verify → commit"
  echo -e "    ${C2}crouted${NC}      Opus research → Sonnet code → review"
  echo -e "    ${C2}claude-loop${NC}  Continuous dev with safety gates"
  echo -e "    ${C2}cfix/cclean${NC}  Quick fix / cleanup commands"
  echo ""
  echo -e "  ${C1}Features Enabled${NC}"
  echo -e "    ${C5}▸${NC} Agent Teams (Swarm Mode)"
  echo -e "    ${C5}▸${NC} Continuous Learning Observer"
  echo -e "    ${C5}▸${NC} Cost Tracking"
  echo -e "    ${C5}▸${NC} 4 Learned Instincts"
  echo ""
  echo -e "${C1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${BOLD}Next steps:${NC}"
  echo -e "    1. ${C2}source ~/.claude/bin/claude-aliases.sh${NC}  (or restart terminal)"
  echo -e "    2. Open a project and run: ${C2}claude${NC}"
  echo -e "    3. Try: ${C3}'Please use a team of specialists for this'${NC}"
  echo ""
  echo -e "  Reference: ${CYAN}~/.claude/contexts/ORCHESTRATION-REFERENCE.md${NC}"
  echo ""
}

# ── Parse args ─────────────────────────────────────────────────
DRY_RUN=false
SKIP_SHELL=false
FORCE=false
SKIP_ECC=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)    DRY_RUN=true;   shift ;;
    --skip-shell) SKIP_SHELL=true; shift ;;
    --force)      FORCE=true;     shift ;;
    --skip-ecc)   SKIP_ECC=true;  shift ;;
    --help|-h)
      echo "Usage: install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run      Show what would be installed without writing files"
      echo "  --skip-shell   Don't modify shell profile (.bashrc/.zshrc)"
      echo "  --skip-ecc     Don't check for ECC installation"
      echo "  --force        Overwrite existing files instead of skipping"
      echo "  --help         Show this help"
      exit 0
      ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Banner ─────────────────────────────────────────────────────
show_banner

if [ "$DRY_RUN" = true ]; then
  warn "DRY RUN — no files will be written"
  echo ""
fi

# ── Prerequisites ──────────────────────────────────────────────
header "Checking prerequisites..."

PREREQS_OK=true

if command -v node &>/dev/null; then
  log "Node.js $(node -v)"
else
  err "Node.js not found — required for hooks and scripts"
  PREREQS_OK=false
fi

if command -v claude &>/dev/null; then
  log "Claude Code $(claude --version 2>/dev/null | head -1)"
else
  warn "Claude Code CLI not found in PATH (may work if installed elsewhere)"
fi

if command -v git &>/dev/null; then
  log "Git $(git --version | awk '{print $3}')"
else
  warn "Git not found — some features (worktrees, session save) won't work"
fi

# Detect OS
OS="unknown"
case "$(uname -s)" in
  Linux*)   OS="linux" ;;
  Darwin*)  OS="macos" ;;
  MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
esac
log "Platform: ${OS} ($(uname -m))"

if [ "$PREREQS_OK" = false ]; then
  err "Missing required prerequisites. Install them and re-run."
  exit 1
fi

# ── Check ECC ──────────────────────────────────────────────────
if [ "$SKIP_ECC" = false ]; then
  header "Checking ECC (Everything Claude Code)..."

  if [ -f "${CLAUDE_HOME}/ecc/install-state.json" ]; then
    ECC_STATE="${CLAUDE_HOME}/ecc/install-state.json"
    if command -v cygpath &>/dev/null; then
      ECC_STATE="$(cygpath -w "$ECC_STATE")"
    fi
    ECC_PROFILE=$(node -e "try{const s=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(s.request.profile||'custom')}catch{console.log('unknown')}" "$ECC_STATE" 2>/dev/null || echo "unknown")
    log "ECC installed (profile: ${ECC_PROFILE})"
  else
    warn "ECC not detected. This setup layers on top of ECC."
    warn "Install ECC first: git clone https://github.com/affaan-m/everything-claude-code && cd everything-claude-code && npm install && bash install.sh --profile full"
    echo ""
    read -p "Continue without ECC? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
fi

# ── Helper: safe copy ─────────────────────────────────────────
safe_copy() {
  local src="$1"
  local dest="$2"
  local label="${3:-$(basename "$src")}"

  if [ "$DRY_RUN" = true ]; then
    if [ -f "$dest" ] && [ "$FORCE" = false ]; then
      info "SKIP (exists): ${label} → ${dest}"
    else
      info "WOULD COPY: ${label} → ${dest}"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -f "$dest" ] && [ "$FORCE" = false ]; then
    info "Skip (exists): ${label}"
    return 0
  fi

  cp "$src" "$dest"
  log "Installed: ${label}"
}

# ── Install Context Profiles ──────────────────────────────────
header "Installing context profiles..."

safe_copy "${SCRIPT_DIR}/contexts/dev.md"         "${CLAUDE_HOME}/contexts/dev.md"         "contexts/dev.md"
safe_copy "${SCRIPT_DIR}/contexts/orchestrate.md"  "${CLAUDE_HOME}/contexts/orchestrate.md"  "contexts/orchestrate.md"
safe_copy "${SCRIPT_DIR}/contexts/review.md"       "${CLAUDE_HOME}/contexts/review.md"       "contexts/review.md"
safe_copy "${SCRIPT_DIR}/contexts/research.md"     "${CLAUDE_HOME}/contexts/research.md"     "contexts/research.md"

# ── Install Reference Doc ─────────────────────────────────────
header "Installing orchestration reference..."

safe_copy "${SCRIPT_DIR}/reference/ORCHESTRATION-REFERENCE.md" \
          "${CLAUDE_HOME}/contexts/ORCHESTRATION-REFERENCE.md" \
          "reference/ORCHESTRATION-REFERENCE.md"

# ── Install Automation Scripts ────────────────────────────────
header "Installing automation scripts..."

for script in "${SCRIPT_DIR}/bin/"*.sh; do
  name="$(basename "$script")"
  safe_copy "$script" "${CLAUDE_HOME}/bin/${name}" "bin/${name}"
  if [ "$DRY_RUN" = false ]; then
    chmod +x "${CLAUDE_HOME}/bin/${name}" 2>/dev/null || true
  fi
done

# ── Install Instincts ────────────────────────────────────────
header "Installing learned instincts..."

INSTINCT_DIR="${CLAUDE_HOME}/homunculus/instincts/personal"
if [ "$DRY_RUN" = false ]; then
  mkdir -p "$INSTINCT_DIR"
  mkdir -p "${CLAUDE_HOME}/homunculus/instincts/inherited"
  mkdir -p "${CLAUDE_HOME}/homunculus/evolved/agents"
  mkdir -p "${CLAUDE_HOME}/homunculus/evolved/skills"
  mkdir -p "${CLAUDE_HOME}/homunculus/evolved/commands"
fi

for instinct in "${SCRIPT_DIR}/instincts/"*.md; do
  [ -f "$instinct" ] || continue
  name="$(basename "$instinct")"
  safe_copy "$instinct" "${INSTINCT_DIR}/${name}" "instincts/${name}"
done

# ── Create Session Data Directory ─────────────────────────────
if [ "$DRY_RUN" = false ]; then
  mkdir -p "${CLAUDE_HOME}/session-data"
  mkdir -p "${CLAUDE_HOME}/plans"
  log "Created: session-data/ and plans/ directories"
fi

# ── Merge Env Settings into settings.json ─────────────────────
header "Configuring settings.json..."

SETTINGS_FILE="${CLAUDE_HOME}/settings.json"

if [ "$DRY_RUN" = false ]; then
  if [ -f "$SETTINGS_FILE" ]; then
    # Convert paths for Node.js on Windows (POSIX /c/Users → C:\Users)
    NODE_SETTINGS="$SETTINGS_FILE"
    NODE_ENVFILE="${SCRIPT_DIR}/config/env-settings.json"
    if command -v cygpath &>/dev/null; then
      NODE_SETTINGS="$(cygpath -w "$SETTINGS_FILE")"
      NODE_ENVFILE="$(cygpath -w "${SCRIPT_DIR}/config/env-settings.json")"
    fi

    # Merge env vars non-destructively (only add keys that don't exist)
    node -e "
      const fs = require('fs');
      const settings = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
      const newEnv = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

      if (!settings.env) settings.env = {};

      let added = 0;
      for (const [key, value] of Object.entries(newEnv)) {
        if (!(key in settings.env)) {
          settings.env[key] = value;
          added++;
          console.log('[✓] Added env: ' + key + '=' + value);
        } else {
          console.log('[i] Skip env (exists): ' + key + '=' + settings.env[key]);
        }
      }

      if (added > 0) {
        fs.writeFileSync(process.argv[1], JSON.stringify(settings, null, 2) + '\n');
      }
    " "$NODE_SETTINGS" "$NODE_ENVFILE" 2>/dev/null || warn "Could not merge env settings (settings.json may not exist yet)"
  else
    warn "settings.json not found at ${SETTINGS_FILE} — create it or run Claude Code first"
  fi
else
  info "WOULD MERGE env vars: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1, ECC_HOOK_PROFILE=standard, CLAUDE_CODE_ENABLE_COST_TRACKING=1"
fi

# ── Enable Observer ───────────────────────────────────────────
header "Configuring continuous learning observer..."

CLV2_CONFIG_PATHS=(
  "${CLAUDE_HOME}/skills/continuous-learning-v2/config.json"
  "${CLAUDE_HOME}/plugins/cache/everything-claude-code/*/latest/skills/continuous-learning-v2/config.json"
)

OBSERVER_UPDATED=false
for config_path in "${CLV2_CONFIG_PATHS[@]}"; do
  # Handle glob expansion
  for resolved in $config_path; do
    if [ -f "$resolved" ]; then
      if [ "$DRY_RUN" = false ]; then
        cp "${SCRIPT_DIR}/config/observer-config.json" "$resolved"
        log "Observer enabled: $(basename "$(dirname "$(dirname "$resolved")")")/config.json"
        OBSERVER_UPDATED=true
      else
        info "WOULD UPDATE: $resolved (observer.enabled=true)"
        OBSERVER_UPDATED=true
      fi
      break
    fi
  done
  [ "$OBSERVER_UPDATED" = true ] && break
done

if [ "$OBSERVER_UPDATED" = false ]; then
  warn "CLv2 config not found — observer not configured (install ECC first)"
fi

# ── Shell Profile Integration ─────────────────────────────────
if [ "$SKIP_SHELL" = false ]; then
  header "Shell profile integration..."

  ALIAS_LINE="source \"\${HOME}/.claude/bin/claude-aliases.sh\""
  SHELL_PROFILE=""

  # Detect shell profile
  if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "zsh" ]; then
    SHELL_PROFILE="${HOME}/.zshrc"
  elif [ -f "${HOME}/.bash_profile" ]; then
    SHELL_PROFILE="${HOME}/.bash_profile"
  elif [ -f "${HOME}/.bashrc" ]; then
    SHELL_PROFILE="${HOME}/.bashrc"
  else
    SHELL_PROFILE="${HOME}/.bashrc"
  fi

  if [ -f "$SHELL_PROFILE" ] && grep -qF "claude-aliases.sh" "$SHELL_PROFILE" 2>/dev/null; then
    log "Shell profile already configured: ${SHELL_PROFILE}"
  else
    if [ "$DRY_RUN" = false ]; then
      echo ""
      info "Add aliases to ${SHELL_PROFILE}?"
      info "This adds: ${ALIAS_LINE}"
      read -p "Add to shell profile? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Claude Power Setup aliases" >> "$SHELL_PROFILE"
        echo "$ALIAS_LINE" >> "$SHELL_PROFILE"
        log "Added aliases to ${SHELL_PROFILE}"
      else
        info "Skipped. Add manually: ${ALIAS_LINE}"
      fi
    else
      info "WOULD ASK to add aliases to: ${SHELL_PROFILE}"
    fi
  fi
fi

# ── Write Marker File ────────────────────────────────────────
if [ "$DRY_RUN" = false ]; then
  cat > "$MARKER_FILE" << EOF
{
  "version": "${VERSION}",
  "installed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "platform": "${OS}",
  "components": [
    "contexts",
    "bin-scripts",
    "instincts",
    "env-settings",
    "observer-config",
    "reference-doc"
  ]
}
EOF
fi

# ── Summary ───────────────────────────────────────────────────
show_summary
