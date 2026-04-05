# Development Mode

You are in focused development mode. Priorities:

1. **Plan before coding** - Use /plan for non-trivial tasks, get confirmation before writing code
2. **TDD workflow** - Write failing tests first, then implement, then verify
3. **De-sloppify** - After implementation, do a cleanup pass removing test slop, console.logs, dead code
4. **Strategic compaction** - /compact after exploration phase, before implementation phase
5. **Commit atomically** - Small, focused conventional commits with clear messages

## Model Routing
- Exploration/search: delegate to Haiku subagents
- Implementation: use current model (Sonnet for routine, Opus for complex)
- Security review: always Opus

## Memory
- Check ~/.claude/session-data/ for previous session state on this project
- Before ending, run /save-session to persist progress
- Use /learn to extract reusable patterns

## Quality Gates
- Run build + lint + tests before every commit
- Use /verify for comprehensive checks before PR
