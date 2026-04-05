#!/bin/bash
# ~/.claude/bin/claude-session-save.sh
# Save current session state for cross-session continuity
# Called automatically by Stop hook, or manually via /save-session
#
# Saves to: ~/.claude/session-data/YYYY-MM-DD-HHMMSS-{project}.md

set -euo pipefail

PROJECT_NAME="${1:-$(basename "$(pwd)")}"
TIMESTAMP="$(date +%Y-%m-%d-%H%M%S)"
SESSION_DIR="$HOME/.claude/session-data"
SESSION_FILE="${SESSION_DIR}/${TIMESTAMP}-${PROJECT_NAME}.md"

mkdir -p "$SESSION_DIR"

# Get git context
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'no-git')"
LAST_COMMITS="$(git log --oneline -5 2>/dev/null || echo 'none')"
UNCOMMITTED="$(git diff --stat HEAD 2>/dev/null || echo 'none')"
UNTRACKED="$(git ls-files --others --exclude-standard 2>/dev/null | head -10 || echo 'none')"

cat > "$SESSION_FILE" << EOF
# Session: ${PROJECT_NAME}
**Date:** ${TIMESTAMP}
**Branch:** ${BRANCH}
**Working Directory:** $(pwd)

## Last 5 Commits
\`\`\`
${LAST_COMMITS}
\`\`\`

## Uncommitted Changes
\`\`\`
${UNCOMMITTED}
\`\`\`

## Untracked Files
\`\`\`
${UNTRACKED}
\`\`\`

## What Was Accomplished
<!-- Fill in or let Claude update -->

## What's Left To Do
<!-- Fill in or let Claude update -->

## Approaches That Worked
<!-- Fill in with evidence -->

## Approaches That Failed
<!-- Fill in so we don't repeat them -->

## Key Files Modified
<!-- List the important files touched this session -->

EOF

echo "Session saved: ${SESSION_FILE}"
