# Optimal Claude Code Orchestration Setup

> Personal reference for maximum-efficiency Claude Code usage.
> Last updated: 2026-04-05

## Quick Reference

### Mode-Switched Sessions
```bash
source ~/.claude/bin/claude-aliases.sh

cdev          # Development mode (TDD, quality gates)
corchestrate  # Team lead mode (spawn specialists, delegate)
creview       # Code review mode (security-first, dual-model)
cresearch     # Research mode (read-only, document findings)
```

### Agent Teams (Swarm Mode)
Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json.

```
# Just ask for a team:
> Build a REST API with auth, rate limiting, and tests.
> Please use a team of specialists for this.

# Claude spawns teammates in isolated worktrees:
# - Each gets fresh context window (~40% utilization)
# - Self-organize via shared task board
# - Communicate via @mentions
# - Max 5 teammates
```

### Automation Pipelines
```bash
# Sequential pipeline (implement -> de-slop -> verify -> commit)
cpipeline "Implement OAuth2 login in src/auth/"

# Model-routed pipeline (Opus research -> Sonnet implement -> Opus review)
crouted "Add caching layer to API endpoints"

# Continuous loop with safety controls
~/.claude/bin/claude-loop.sh "Add tests for all untested functions" --max-runs 8

# Single-shot commands
cfix      # Build + lint + test + fix failures
cclean    # Remove slop from uncommitted changes
ccommit   # Auto-commit with conventional message
caudit    # Security scan + harness audit
```

### Slash Commands
```
/plan               Plan before coding (WAIT for confirm)
/tdd                Test-driven development
/verify             Full verification loop
/code-review        Quality review
/build-fix          Fix build errors
/santa-loop         Dual-model adversarial review
/team-builder       Compose agent team from specialists
/multi-workflow     Multi-model collaboration (Claude+Codex+Gemini)
/loop-start         Start managed autonomous loop
/learn              Extract reusable patterns
/save-session       Persist session state
/resume-session     Load previous session
/instinct-status    View learned instincts
/promote            Move instincts project -> global
/security-scan      Scan .claude/ for vulnerabilities
/harness-audit      Score your setup
/aside              Side question without losing context
```

## Architecture: The Full Stack

```
+-----------------------------------------------------------+
| YOU (the developer)                                       |
+-----------------------------------------------------------+
| MODES: cdev | orchestrate | creview | cresearch           |
+-----------------------------------------------------------+

ORCHESTRATION LAYER
+----------+ +----------+ +-----------+ +--------------+
| Agent    | | Swarm    | | Santa     | | Multi-Model  |
| Teams    | | Mode     | | Loop      | | Workflow     |
| (natives)| |(TeamTool)| |(dual rev) | |(Claude+Codex)|
+----------+ +----------+ +-----------+ +--------------+

LOOP ENGINE
+-----------+ +------------+ +----------+ +------------+
| Sequential| | Continuous | | Infinite | | Ralphinho  |
| Pipeline  | | PR Loop    | | Agentic  | | RFC DAG    |
| (claude-p)| | (CI gates) | | (waves)  | |(merge que) |
+-----------+ +------------+ +----------+ +------------+

QUALITY LAYER
+-----------+ +--------+ +----------+ +----------------+
| TDD       | | Verify | | De-Slop  | | Quality Gate   |
| Guide     | | Loop   | | Pass     | | (PostToolUse)  |
+-----------+ +--------+ +----------+ +----------------+

MEMORY & LEARNING
+--------------+ +--------------+ +------------------+
| Session Save | | Instincts    | | Strategic        |
| /Resume      | | (v2.1)       | | Compact          |
| ~/.claude/   | | observe ->   | | (phase-aware)    |
| session-data/| | score ->     | |                  |
|              | | promote ->   | |                  |
|              | | evolve       | |                  |
+--------------+ +--------------+ +------------------+

SECURITY & HOOKS
+--------------+ +--------------+ +------------------+
| PreToolUse   | | PostToolUse  | | Stop / Session   |
| - security   | | - quality    | | - session save   |
| - config prot| | - cost track | | - evaluate       |
| - commit qual| | - build notif| | - cost report    |
| - observe    | | - observe    | | - desktop notify |
+--------------+ +--------------+ +------------------+

38 AGENTS | 200+ SKILLS | 30+ HOOKS | 12 LANG RULES
```

## Self-Improvement Loop

### The Full Recursive Learning Pipeline

```
+-----------------------------------------------------------------+
| RECURSIVE SELF-IMPROVEMENT                                      |
+-----------------------------------------------------------------+

LAYER 1: OBSERVATION (automatic, every tool use)
+---------------------------------------------------------+
| PreToolUse hook  -> observe.sh -> observations.jsonl    |
| PostToolUse hook -> observe.sh -> observations.jsonl    |
|                                                         |
| Captures: tool name, input, output, session, project    |
| Scrubs: secrets, API keys (regex-based redaction)       |
| Scoped: per-project (git remote hash) or global         |
| Auto-purge: files >10MB archived, >30 days deleted      |
+---------------------------------------------------------+
                         |
                         v

LAYER 2: PATTERN DETECTION (background observer, Haiku)
+---------------------------------------------------------+
| Observer agent runs every 5 min (now ENABLED)           |
| Detects:                                                |
|   - User corrections -> instinct                        |
|   - Error resolutions -> instinct                       |
|   - Repeated workflows -> instinct                      |
|   - Scope decision: project or global?                  |
|                                                         |
| Also: /learn (manual) and /learn-eval (self-evaluated)  |
+---------------------------------------------------------+
                         |
                         v

LAYER 3: INSTINCTS (atomic learned behaviors)
+---------------------------------------------------------+
| Format: YAML with confidence scoring                    |
|                                                         |
| id: prefer-functional-style                             |
| trigger: "when writing new functions"                   |
| confidence: 0.7  (0.3=tentative -> 0.9=certain)         |
| domain: code-style                                      |
| scope: project                                          |
|                                                         |
| Storage:                                                |
| Per-project: ~/.claude/homunculus/projects/<hash>/      |
| Global: ~/.claude/homunculus/instincts/personal/        |
|                                                         |
| Confidence evolves:                                     |
|   + pattern observed again, user does not correct       |
|   - user explicitly corrects, contradicting evidence    |
+---------------------------------------------------------+
                         |
                         v

LAYER 4: PROMOTION (project -> global)
+---------------------------------------------------------+
| /promote moves high-confidence project instincts        |
| to global scope                                         |
|                                                         |
| Auto-promote criteria:                                  |
|   - Same instinct in 2+ projects                        |
|   - Average confidence >= 0.8                           |
|                                                         |
| Scope guide:                                            |
|   Project: React hooks, Django patterns, file structure |
|   Global: security practices, git workflow, tool prefs  |
+---------------------------------------------------------+
                         |
                         v

LAYER 5: EVOLUTION (instincts -> skills/agents/commands)
+---------------------------------------------------------+
| /evolve clusters 5+ related instincts into:             |
|   - SKILL.md (workflow definition)                      |
|   - agent.md (specialist subagent)                      |
|   - command.md (slash command)                          |
|                                                         |
| Output: ~/.claude/homunculus/evolved/                   |
|         or projects/<hash>/evolved/                     |
+---------------------------------------------------------+
                         |
                         v

LAYER 6: V1 LEARNED SKILLS (already accumulated)
+---------------------------------------------------------+
| 7 skills already learned from previous sessions:        |
|   - azure-copilot-proxy-llm-gateway                     |
|   - deerflow-model-thinking-modes                       |
|   - deerflow-windows-docker-setup                       |
|   - openclaw-gateway-systemd-fix                        |
|   - openclaw-pi-security-hardening                      |
|   - pamir-device-reference                              |
|   - syncthing-obsidian-vault-sync                       |
|                                                         |
| Location: ~/.claude/skills/learned/                     |
+---------------------------------------------------------+

+-----------------------------------------------------------------+
| NEXT SESSION: All instincts + learned skills auto-loaded        |
| Better behavior -> more accurate instincts -> compounds         |
+-----------------------------------------------------------------+
```

### Learning Commands Quick Reference

| Command | What it does | When to use |
|---------|-------------|-------------|
| `/learn` | Extract reusable patterns from session | End of productive sessions |
| `/learn-eval` | Extract + self-evaluate quality before saving | When you want higher-quality extractions |
| `/instinct-status` | Show all instincts with confidence scores | Periodic review of what's been learned |
| `/promote` | Move project instincts → global scope | When pattern appears in 2+ projects |
| `/promote --dry-run` | Preview promotions without changing | Before committing to promotions |
| `/evolve` | Cluster instincts → generate skills/agents | When you have 5+ related instincts |
| `/prune` | Delete old instincts never promoted (>30 days) | Monthly cleanup |
| `/projects` | List all known projects + instinct counts | Overview of learning state |
| `/instinct-export` | Export instincts to shareable file | Share patterns with team |
| `/instinct-import` | Import instincts from file or URL | Adopt team patterns |
| `/skill-create` | Generate skills from git history | Bootstrap learning from existing code |

### Current Learning State

```
Projects tracked: 3
  - everything-claude-code (115 observations)
  - Claude4Github (523 observations)
  - openclaw (180 observations)

Total observations: 818
Instincts created: 0 (observer just enabled)
V1 learned skills: 7
Observer: ENABLED (was disabled, now active)
```

### Recommended Learning Workflow

```bash
# During session: automatic (hooks capture everything)

# End of productive session:
/learn                    # Extract patterns manually
# OR just let the observer find them (auto every 5 min)

# Weekly:
/instinct-status          # Review what was learned
/promote                  # Move cross-project patterns to global
/prune                    # Clean old unconfirmed instincts

# Monthly:
/evolve                   # Generate skills from instinct clusters
/skill-health             # Dashboard of your skill portfolio
/harness-audit            # Score your overall setup
```

## Decision Matrix: Which Tool When

| Situation | Tool |
|-----------|------|
| Single focused task | Just ask Claude directly |
| Multi-file feature (independent parts) | Agent Teams (swarm) |
| Feature with spec/RFC | Ralphinho RFC DAG |
| Need parallel perspectives | /team-builder |
| Need adversarial quality assurance | /santa-loop |
| Cross-model diversity | /multi-workflow |
| Scripted CI/CD automation | cpipeline / claude-loop |
| Research before coding | cresearch mode |
| PR review | creview mode |
| Side question mid-task | /aside |
