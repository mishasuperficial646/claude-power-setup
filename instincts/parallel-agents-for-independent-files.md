---
id: parallel-agents-for-independent-files
trigger: "when building features that span multiple independent files"
confidence: 0.8
domain: workflow
source: session-observation
scope: global
created_at: "2026-04-05"
---

# Parallel Agents for Independent Files

## Action
When a feature requires creating 3+ files that don't depend on each other (e.g., auth middleware, CRUD routes, tests), spawn parallel agents — one per file group. Each agent works in isolation with its own context window.

## Evidence
- Session 2026-04-05: 3 parallel agents built auth, CRUD routes, and tests simultaneously
- All 3 completed successfully with 24 passing tests
- Total wall-clock time was bounded by the slowest agent, not the sum of all agents
- No file conflicts because each agent owned distinct files

## When NOT to use
- Files that depend on each other's types/interfaces (build sequentially)
- Single-file changes (overhead not worth it)
- Files that import from each other circularly
