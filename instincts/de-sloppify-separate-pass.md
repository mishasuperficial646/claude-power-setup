---
id: de-sloppify-separate-pass
trigger: "after implementing a feature with TDD"
confidence: 0.85
domain: workflow
source: session-observation
scope: global
created_at: "2026-04-05"
---

# De-Sloppify as Separate Pass

## Action
After implementation, always run a separate cleanup agent that did NOT write the original code. Focus on: console.logs, redundant type checks in tests, tests that test framework behavior, commented-out code.

## Evidence
- Session 2026-04-05: cleanup agent removed 5 lines of slop (3 redundant assertions, 2 console statements)
- All 24 tests still passed after cleanup
- The cleanup agent found issues the implementing agents wouldn't have caught (author bias)

## Key Principle
Two focused agents > one constrained agent. Don't add "don't do X" to the implementation prompt. Let the implementer be thorough, then clean up separately.
