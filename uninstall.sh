#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  Claude Power Setup — Uninstaller                           ║
# ║  Removes only files installed by this package.              ║
# ║  Never touches ECC, hooks, plugins, or user-modified files. ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

CLAUDE_HOME="${HOME}/.claude"
MARKER_FILE="${CLAUDE_HOME}/.claude-power-setup-installed"

# ── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*"; }
info() { echo -e "${CYAN}[i]${NC} $*"; }

# ── Parse args ─────────────────────────────────────────────────
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --help|-h)
      echo "Usage: uninstall.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run  Show what would be removed without deleting"
      echo "  --help     Show this help"
      exit 0
      ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Check marker ──────────────────────────────────────────────
if [ ! -f "$MARKER_FILE" ]; then
  warn "Claude Power Setup does not appear to be installed."
  warn "Marker file not found: ${MARKER_FILE}"
  echo ""
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
  fi
fi

echo ""
echo -e "${BOLD}Claude Power Setup — Uninstaller${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  warn "DRY RUN — no files will be deleted"
  echo ""
fi

# ── Helper: safe remove ─────────────────────────────────────────
safe_remove() {
  local path="$1"
  local label="${2:-$path}"

  if [ ! -e "$path" ]; then
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    info "WOULD REMOVE: ${label}"
  else
    rm -f "$path"
    log "Removed: ${label}"
  fi
}

# ── Remove context profiles ─────────────────────────────────────
echo -e "${BOLD}Removing context profiles...${NC}"
safe_remove "${CLAUDE_HOME}/contexts/dev.md"         "contexts/dev.md"
safe_remove "${CLAUDE_HOME}/contexts/orchestrate.md" "contexts/orchestrate.md"
safe_remove "${CLAUDE_HOME}/contexts/review.md"      "contexts/review.md"
safe_remove "${CLAUDE_HOME}/contexts/research.md"    "contexts/research.md"

# ── Remove reference doc ─────────────────────────────────────────
echo -e "${BOLD}Removing orchestration reference...${NC}"
safe_remove "${CLAUDE_HOME}/contexts/ORCHESTRATION-REFERENCE.md" "ORCHESTRATION-REFERENCE.md"

# ── Remove automation scripts ────────────────────────────────────
echo -e "${BOLD}Removing automation scripts...${NC}"
safe_remove "${CLAUDE_HOME}/bin/claude-aliases.sh"      "bin/claude-aliases.sh"
safe_remove "${CLAUDE_HOME}/bin/claude-loop.sh"         "bin/claude-loop.sh"
safe_remove "${CLAUDE_HOME}/bin/claude-session-save.sh" "bin/claude-session-save.sh"

# ── Remove instincts ────────────────────────────────────────────
echo -e "${BOLD}Removing installed instincts...${NC}"
INSTINCT_DIR="${CLAUDE_HOME}/homunculus/instincts/personal"
safe_remove "${INSTINCT_DIR}/parallel-agents-for-independent-files.md" "instincts/parallel-agents-for-independent-files.md"
safe_remove "${INSTINCT_DIR}/de-sloppify-separate-pass.md"             "instincts/de-sloppify-separate-pass.md"
safe_remove "${INSTINCT_DIR}/dual-review-catches-more.md"              "instincts/dual-review-catches-more.md"
safe_remove "${INSTINCT_DIR}/uuid-esm-incompatibility-jest.md"         "instincts/uuid-esm-incompatibility-jest.md"

# ── Revert env settings ─────────────────────────────────────────
echo -e "${BOLD}Reverting env settings...${NC}"

SETTINGS_FILE="${CLAUDE_HOME}/settings.json"

if [ -f "$SETTINGS_FILE" ] && command -v node &>/dev/null; then
  # Convert path for Node.js on Windows
  NODE_SETTINGS="$SETTINGS_FILE"
  if command -v cygpath &>/dev/null; then
    NODE_SETTINGS="$(cygpath -w "$SETTINGS_FILE")"
  fi

  if [ "$DRY_RUN" = true ]; then
    info "WOULD REVERT env keys: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, ECC_HOOK_PROFILE, CLAUDE_CODE_ENABLE_COST_TRACKING"
  else
    node -e "
      const fs = require('fs');
      const settings = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
      if (!settings.env) process.exit(0);

      // Only remove keys if they match what we installed
      const expected = {
        'CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS': '1',
        'ECC_HOOK_PROFILE': 'standard',
        'CLAUDE_CODE_ENABLE_COST_TRACKING': '1'
      };

      let reverted = 0;
      for (const [key, val] of Object.entries(expected)) {
        if (settings.env[key] === val) {
          delete settings.env[key];
          reverted++;
          console.log('[✓] Reverted env: ' + key);
        } else if (key in settings.env) {
          console.log('[i] Skip env (user-modified): ' + key + '=' + settings.env[key]);
        }
      }

      if (reverted > 0) {
        fs.writeFileSync(process.argv[1], JSON.stringify(settings, null, 2) + '\n');
      }
    " "$NODE_SETTINGS" 2>/dev/null || warn "Could not revert env settings"
  fi
else
  warn "Cannot revert env settings (settings.json or node not found)"
fi

# ── Remove alias from shell profile ──────────────────────────────
echo -e "${BOLD}Cleaning shell profile...${NC}"

for profile in "${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.zshrc"; do
  if [ -f "$profile" ] && grep -qF "claude-aliases.sh" "$profile" 2>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
      info "WOULD REMOVE alias line from: ${profile}"
    else
      # Remove the alias line and the comment above it
      sed -i.bak '/# Claude Power Setup aliases/d' "$profile" 2>/dev/null || true
      sed -i.bak '/claude-aliases\.sh/d' "$profile" 2>/dev/null || true
      rm -f "${profile}.bak" 2>/dev/null || true
      log "Cleaned: ${profile}"
    fi
  fi
done

# ── Remove marker file ──────────────────────────────────────────
safe_remove "$MARKER_FILE" ".claude-power-setup-installed"

# ── Summary ──────────────────────────────────────────────────────
echo ""
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}Dry run complete. No files were deleted.${NC}"
else
  echo -e "${GREEN}Uninstall complete.${NC}"
  echo ""
  echo "Preserved:"
  echo "  - ECC hooks, plugins, and scripts"
  echo "  - Your settings.json (env keys reverted only if unmodified)"
  echo "  - Session data and plans directories"
  echo "  - Any instincts you created yourself"
fi
echo ""
