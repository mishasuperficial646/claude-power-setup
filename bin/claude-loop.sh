#!/bin/bash
# ~/.claude/bin/claude-loop.sh
# Continuous development loop with safety controls
#
# Usage:
#   claude-loop "Add tests for untested functions" --max-runs 5
#   claude-loop "Fix all linter errors" --max-runs 10 --mode fast
#   claude-loop "Improve coverage to 80%" --max-runs 8 --model sonnet

set -euo pipefail

PROMPT="${1:?Usage: claude-loop \"prompt\" [--max-runs N] [--mode safe|fast] [--model MODEL]}"
shift

MAX_RUNS=5
MODE="safe"
MODEL_ARGS=()
NOTES_FILE="SHARED_TASK_NOTES.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-runs) MAX_RUNS="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --model) MODEL_ARGS=(--model "$2"); shift 2 ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

echo "=== Claude Loop ==="
echo "Prompt: ${PROMPT}"
echo "Max runs: ${MAX_RUNS}"
echo "Mode: ${MODE}"
echo "Model: ${MODEL_ARGS[*]:-default}"
echo ""

# Initialize shared notes
if [ ! -f "$NOTES_FILE" ]; then
  cat > "$NOTES_FILE" << 'EOF'
## Progress
(auto-updated by loop)

## Next Steps
(auto-updated by loop)

## Issues Found
(auto-updated by loop)
EOF
fi

QUALITY_GATE=""
if [ "$MODE" = "safe" ]; then
  QUALITY_GATE='After implementation, run the full build + lint + test suite. Fix any failures before completing.'
fi

COMPLETED=0
for i in $(seq 1 "$MAX_RUNS"); do
  COMPLETED=$i
  echo ""
  echo "━━━ Iteration ${i}/${MAX_RUNS} ━━━"

  ITERATION_PROMPT="You are on iteration ${i} of ${MAX_RUNS} of a continuous development loop.

Read ${NOTES_FILE} for context from previous iterations.

TASK: ${PROMPT}

${QUALITY_GATE}

After completing your work:
1. Update ${NOTES_FILE} with what you accomplished and what's left
2. If the task is fully complete, include the line: LOOP_COMPLETE
3. Commit your changes with a conventional commit message"

  claude -p "${MODEL_ARGS[@]}" "$ITERATION_PROMPT"

  # Check for completion signal
  if grep -q "LOOP_COMPLETE" "$NOTES_FILE" 2>/dev/null; then
    echo ""
    echo "=== Loop completed at iteration ${COMPLETED} (task signaled complete) ==="
    break
  fi
done

echo ""
echo "=== Loop finished after ${COMPLETED} iterations ==="
echo "Notes: $(head -20 "$NOTES_FILE")"
