# Claude Power Setup

Multi-agent orchestration, automation pipelines, and recursive self-improvement for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Layers on top of [ECC (Everything Claude Code)](https://github.com/affaan-m/everything-claude-code).

## Prerequisites

| Requirement | Required | Notes |
|-------------|----------|-------|
| **Node.js** 18+ | Yes | Hooks and scripts depend on it |
| **Claude Code CLI** | Yes | `npm install -g @anthropic-ai/claude-code` |
| **Git** | Recommended | Worktrees, session save, loop runner |
| **ECC** | Recommended | This setup extends ECC's hooks and skills |

## Quick Install

### Linux / macOS / Git Bash (Windows)

```bash
git clone https://github.com/YOUR_USERNAME/claude-power-setup.git
cd claude-power-setup
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/YOUR_USERNAME/claude-power-setup.git
cd claude-power-setup
powershell -ExecutionPolicy Bypass -File install.ps1
```

### npm (any platform)

```bash
npx claude-power-setup
```

### Options

```
--dry-run      Show what would be installed without writing files
--force        Overwrite existing files instead of skipping
--skip-shell   Don't modify shell profile (.bashrc/.zshrc)
--skip-ecc     Don't check for ECC installation
```

## What's Included

### Context Profiles (Mode Switching)

Switch between purpose-built Claude modes:

```bash
source ~/.claude/bin/claude-aliases.sh

cdev          # Development mode — TDD, quality gates, strategic compaction
corchestrate  # Team lead mode — decompose, delegate, synthesize
creview       # Code review mode — security-first, dual-model review
cresearch     # Research mode — read-only investigation, document findings
```

### Automation Pipelines

```bash
# Sequential: implement -> de-slop -> verify -> commit
cpipeline "Implement OAuth2 login in src/auth/"

# Model-routed: Opus research -> Sonnet implement -> Opus review
crouted "Add caching layer to API endpoints"

# Continuous loop with safety controls
~/.claude/bin/claude-loop.sh "Add tests for untested functions" --max-runs 8

# Quick commands
cfix      # Build + lint + test + fix failures
cclean    # Remove slop from uncommitted changes
ccommit   # Auto-commit with conventional message
caudit    # Security scan + harness audit
```

### Agent Teams (Swarm Mode)

Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Just ask naturally:

```
> Build a REST API with auth, rate limiting, and tests.
> Please use a team of specialists for this.
```

Claude spawns teammates in isolated worktrees — each with fresh context, self-organizing via a shared task board.

### Learned Instincts

Four battle-tested patterns extracted from real development sessions:

| Instinct | Confidence | What It Does |
|----------|------------|--------------|
| Parallel agents for independent files | 0.8 | Spawn parallel agents when 3+ files don't depend on each other |
| De-sloppify as separate pass | 0.85 | Always clean up with a different agent than the one that wrote the code |
| Dual-review catches more | 0.9 | Two independent reviewers find ~45% more issues than one |
| uuid ESM incompatibility | 0.95 | Use crypto.randomUUID() instead of uuid package in Jest/CJS projects |

### Continuous Learning Observer

Watches every tool use, detects patterns, and creates new instincts automatically. Runs every 5 minutes in the background.

## Architecture

```
YOU (developer)
  │
  ├── Mode Selection: cdev | corchestrate | creview | cresearch
  │
  ├── Orchestration: Agent Teams | Swarm Mode | Santa Loop | Multi-Model
  │
  ├── Loop Engine: Sequential Pipeline | Continuous Loop | Model-Routed
  │
  ├── Quality Layer: TDD Guide | Verify Loop | De-Slop Pass
  │
  ├── Memory & Learning: Session Save/Resume | Instincts (v2.1) | Strategic Compact
  │
  └── Security & Hooks: PreToolUse | PostToolUse | Stop/Session hooks
```

See `~/.claude/contexts/ORCHESTRATION-REFERENCE.md` for the full reference.

## File Layout

```
claude-power-setup/
├── install.sh                 # Main installer (bash)
├── install.ps1                # Windows PowerShell wrapper
├── uninstall.sh               # Clean removal
├── package.json               # npm installer
├── README.md                  # This file
├── contexts/                  # Mode profiles
│   ├── dev.md
│   ├── orchestrate.md
│   ├── review.md
│   └── research.md
├── bin/                       # Automation scripts
│   ├── claude-aliases.sh
│   ├── claude-loop.sh
│   └── claude-session-save.sh
├── instincts/                 # Learned patterns
│   ├── parallel-agents-for-independent-files.md
│   ├── de-sloppify-separate-pass.md
│   ├── dual-review-catches-more.md
│   └── uuid-esm-incompatibility-jest.md
├── config/                    # Settings templates
│   ├── env-settings.json
│   └── observer-config.json
└── reference/                 # Full reference doc
    └── ORCHESTRATION-REFERENCE.md
```

## Uninstall

```bash
bash uninstall.sh           # Interactive removal
bash uninstall.sh --dry-run # Preview what would be removed
```

The uninstaller only removes files it installed. It never touches ECC hooks, plugins, session data, user-created instincts, or user-modified settings.

## Key Slash Commands

| Command | Purpose |
|---------|---------|
| `/plan` | Plan before coding |
| `/tdd` | Test-driven development |
| `/verify` | Full verification loop |
| `/code-review` | Quality review |
| `/santa-loop` | Dual-model adversarial review |
| `/team-builder` | Compose agent team |
| `/learn` | Extract reusable patterns |
| `/instinct-status` | View learned instincts |
| `/save-session` | Persist session state |
| `/resume-session` | Load previous session |

## License

MIT
