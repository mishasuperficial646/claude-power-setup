#!/bin/bash
# ~/.claude/bin/claude-aliases.sh
# Source this in your .bashrc or .bash_profile:
#   source ~/.claude/bin/claude-aliases.sh

# ── Helper: launch Claude with a context profile ─────────
_claude_with_context() {
  local ctx="$HOME/.claude/contexts/$1"
  if [ ! -f "$ctx" ]; then
    echo "[!] Context profile not found: $ctx" >&2
    echo "    Run claude-power-setup to reinstall." >&2
    return 1
  fi
  claude --system-prompt "$(cat "$ctx")"
}

# ── Mode-Switched Claude Sessions ──────────────────────────
alias c='claude'
alias cdev='_claude_with_context dev.md'
alias corchestrate='_claude_with_context orchestrate.md'
alias creview='_claude_with_context review.md'
alias cresearch='_claude_with_context research.md'

# ── Quick Non-Interactive Pipelines ────────────────────────
alias cfix='claude -p "Run build + lint + tests. Fix any failures. Do not add features."'
alias cclean='claude -p "Review all uncommitted changes. Remove console.logs, dead code, commented-out code, test slop. Run tests after cleanup."'
alias ccommit='claude -p "Create a conventional commit for all staged changes. Summarize what changed in 1-2 sentences."'
alias caudit='claude -p "Run /security-scan and /harness-audit. Report findings."'

# ── Sequential Pipeline ───────────────────────────────────
# Usage: cpipeline "Implement OAuth2 login in src/auth/"
cpipeline() {
  local spec="$1"
  echo "=== Step 1: Implement ==="
  claude -p "Read the codebase. ${spec}. Write tests first (TDD). Do NOT create documentation files."
  echo "=== Step 2: De-sloppify ==="
  claude -p "Review all uncommitted changes. Remove tests that verify language behavior, redundant type checks, console.logs, commented code. Keep business logic tests. Run test suite."
  echo "=== Step 3: Verify ==="
  claude -p "Run full build, lint, type check, tests. Fix any failures. Do not add features."
  echo "=== Step 4: Commit ==="
  claude -p "Create a conventional commit for all changes. Use a clear, descriptive message."
  echo "=== Pipeline complete ==="
}

# ── Model-Routed Pipeline ─────────────────────────────────
# Usage: crouted "Add caching layer to API endpoints"
crouted() {
  local spec="$1"
  echo "=== Research (Opus) ==="
  claude -p --model opus "Analyze the codebase architecture. Plan how to: ${spec}. Write plan to .claude/plans/current.md"
  echo "=== Implement (Sonnet) ==="
  claude -p "Read .claude/plans/current.md. Implement the plan with TDD."
  echo "=== De-sloppify ==="
  claude -p "Cleanup pass on all uncommitted changes. Remove slop, run tests."
  echo "=== Review (Opus) ==="
  claude -p --model opus "Review all uncommitted changes for security, correctness, performance. Write findings to .claude/plans/review.md"
  echo "=== Fix + Commit ==="
  claude -p "Read .claude/plans/review.md. Fix all critical/high issues. Run tests. Commit."
}

# ── Worktree Helpers ──────────────────────────────────────
# Usage: cwt feature-auth "Implement JWT authentication"
cwt() {
  local name="${1:?Usage: cwt <name> [task]}"
  local task="${2:-}"
  git worktree add -b "feat/${name}" "../${PWD##*/}-${name}" HEAD
  echo "Worktree created: ../$(basename "$PWD")-${name}"
  echo "Run: cd ../$(basename "$PWD")-${name} && claude"
  if [ -n "$task" ]; then
    (cd "../${PWD##*/}-${name}" && claude -p "$task")
  fi
}

# Clean up worktree after merge
cwt-clean() {
  local name="${1:?Usage: cwt-clean <name>}"
  git worktree remove "../${PWD##*/}-${name}" 2>/dev/null
  git branch -d "feat/${name}" 2>/dev/null
  echo "Cleaned: ${name}"
}

echo "[claude-aliases] Loaded: cdev, corchestrate, creview, cresearch, cpipeline, crouted, cwt"
