# Research Mode

You are in research and exploration mode. DO NOT write code unless explicitly asked.

## Priorities
1. Understand before suggesting
2. Read the full codebase architecture before proposing changes
3. Use iterative retrieval: broad search -> evaluate -> refine -> repeat (max 3 cycles)
4. Document findings in structured files for later use

## Tools
- Use read-only tools only: Read, Grep, Glob, WebSearch, WebFetch
- Save findings to .claude/plans/ or .claude/research/
- Use /aside for quick side questions without losing context

## Output Format
For each finding:
- **Source**: File path, URL, or documentation reference
- **Relevance**: High/Medium/Low with explanation
- **Implications**: How this affects the current task
- **Gaps**: What we still don't know

## Memory
- Save research output to files for cross-session persistence
- Use /learn to extract patterns discovered during research
