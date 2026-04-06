<p align="center">
  <img src="assets/banner.svg" alt="Claude Power Setup banner" width="100%">
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License"></a>
  <a href="https://nodejs.org"><img src="https://img.shields.io/badge/Node.js-18%2B-green.svg" alt="Node.js 18+"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/Claude%20Code-Extension-purple.svg" alt="Claude Code"></a>
  <a href="https://www.npmjs.com/package/claude-power-setup"><img src="https://img.shields.io/npm/v/claude-power-setup.svg" alt="npm version"></a>
</p>

<p align="center">
  <strong>Multi-agent orchestration, automation pipelines, and recursive self-improvement for <a href="https://docs.anthropic.com/en/docs/claude-code">Claude Code</a>.</strong>
</p>

---

Layers on top of [ECC (Everything Claude Code)](https://github.com/affaan-m/everything-claude-code). One command to install:  

```bash
npm install -g claude-power-setup
claude-power-setup
```

<video src="https://github.com/shyamsridhar123/claude-power-setup/releases/download/v1.0.0/feature-video.mp4" width="100%" autoplay loop muted playsinline controls></video>

---

## Why This Exists

### The Problem

Claude Code is powerful out of the box, but using it at maximum efficiency requires expertise most developers don't have time to build. You end up with:

- **One mode for everything** — The same approach for research, implementation, review, and debugging. Each of these is a fundamentally different cognitive task, but you're using the same prompt posture for all of them.
- **Serial execution** — Waiting for one agent to finish before starting the next, even when the work is independent. Your 8-core machine is doing one thing at a time.
- **No memory between sessions** — Every session starts from zero. The hard-won lesson from Tuesday's debugging marathon? Gone by Wednesday. The pattern you discovered for your project's test setup? You'll rediscover it next month.
- **Manual quality control** — Remembering to run tests, check security, clean up slop, and review code. Humans forget. Agents don't — if you tell them to.

### The Philosophy

This setup is built on three beliefs about AI-assisted development:

**1. Mode switching is not optional — it's fundamental.**

A developer reviewing code should think differently than a developer writing code. When you're in research mode, you should be read-only and methodical. When you're orchestrating a team, you should decompose and delegate, not implement. Claude Code doesn't enforce this separation. We do — with four purpose-built context profiles that prime the agent for the task at hand.

**2. The agent should get smarter over time, not just the developer.**

Most AI coding tools are stateless. They make the same mistakes on day 100 that they made on day 1. The Continuous Learning system changes this: every tool use is observed, patterns are detected, instincts are created with confidence scores, and high-confidence instincts are promoted from project-scoped to global. Your Claude gets better at *your* codebases, with *your* preferences, automatically.

**3. Orchestration beats implementation.**

The highest-leverage thing a developer can do with AI agents is not write code through them — it's *orchestrate multiple agents in parallel*. One agent researches. Another implements. A third writes tests. A fourth reviews. They work in isolated worktrees with independent context windows, communicate through a shared task board, and produce work that no single agent session could match. This is swarm engineering, and it's the default mode for complex tasks.

### What Makes This Different

This isn't a collection of dotfiles or a prompt library. It's an **operating system layer** for Claude Code:

- **Automation pipelines** (`cpipeline`, `crouted`, `claude-loop`) replace manual multi-step workflows with deterministic, quality-gated sequences
- **Model routing** sends research to Opus and implementation to Sonnet — the right model for the right job
- **Instinct-based learning** means the system evolves from observations, not from you manually curating prompts
- **Safe packaging** — the installer is idempotent, the uninstaller is surgical, and nothing touches your existing ECC setup unless you ask

The result: you spend less time managing the AI and more time thinking about the problem.

---

## Prerequisites

| Requirement | Required | Notes |
|-------------|----------|-------|
| **Node.js** 18+ | Yes | Hooks and scripts depend on it |
| **Claude Code CLI** | Yes | `npm install -g @anthropic-ai/claude-code` |
| **Git** | Recommended | Worktrees, session save, loop runner |
| **ECC** | Recommended | This setup extends ECC's hooks and skills |

## Quick Install

### npm (recommended — any platform)

```bash
npm install -g claude-power-setup
claude-power-setup
```

### Linux / macOS / Git Bash (Windows)

```bash
git clone https://github.com/shyamsridhar123/claude-power-setup.git
cd claude-power-setup
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/shyamsridhar123/claude-power-setup.git
cd claude-power-setup
powershell -ExecutionPolicy Bypass -File install.ps1
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

Switch between purpose-built Claude modes. Each profile primes the agent with different priorities, allowed tools, and quality gates:

```bash
source ~/.claude/bin/claude-aliases.sh

cdev          # Development mode — TDD, quality gates, strategic compaction
corchestrate  # Team lead mode — decompose, delegate, synthesize
creview       # Code review mode — security-first, dual-model review
cresearch     # Research mode — read-only investigation, document findings
```

### Automation Pipelines

Replace multi-step manual workflows with deterministic, scriptable pipelines:

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

Claude spawns teammates in isolated worktrees — each with fresh context, self-organizing via a shared task board. Up to 5 specialists working in parallel: architect, backend, frontend, tester, reviewer, docs.

### Learned Instincts

Four battle-tested patterns extracted from real development sessions. These load automatically and improve agent behavior without prompt engineering:

| Instinct | Confidence | What It Does |
|----------|------------|--------------|
| Parallel agents for independent files | 0.8 | Spawn parallel agents when 3+ files don't depend on each other |
| De-sloppify as separate pass | 0.85 | Always clean up with a different agent than the one that wrote the code |
| Dual-review catches more | 0.9 | Two independent reviewers find ~45% more issues than one |
| uuid ESM incompatibility | 0.95 | Use `crypto.randomUUID()` instead of uuid package in Jest/CJS projects |

### Continuous Learning Observer

The system watches every tool use, detects patterns in your workflow, and creates new instincts automatically:

```
Observe (every tool use) -> Detect (patterns emerge) -> Learn (create instincts)
    -> Promote (project -> global) -> Evolve (instincts -> skills/agents)
```

Instincts have confidence scores (0.3 tentative to 0.95 certain) that evolve as evidence accumulates. High-confidence instincts are promoted from project scope to global scope automatically.

## Architecture

```
YOU (developer)
  |
  +-- Mode Selection: cdev | corchestrate | creview | cresearch
  |
  +-- Orchestration: Agent Teams | Swarm Mode | Santa Loop | Multi-Model
  |
  +-- Loop Engine: Sequential Pipeline | Continuous Loop | Model-Routed
  |
  +-- Quality Layer: TDD Guide | Verify Loop | De-Slop Pass
  |
  +-- Memory & Learning: Session Save/Resume | Instincts (v2.1) | Strategic Compact
  |
  +-- Security & Hooks: PreToolUse | PostToolUse | Stop/Session hooks
```

See `~/.claude/contexts/ORCHESTRATION-REFERENCE.md` for the full reference with architecture diagrams, decision matrices, and workflow examples.

## File Layout

```
claude-power-setup/
├── install.sh                 # Main installer (bash, cross-platform)
├── install.ps1                # Windows PowerShell wrapper
├── uninstall.sh               # Safe removal (only touches what it installed)
├── cli.js                     # npm entry point (npx claude-power-setup)
├── package.json               # npm package config
├── README.md                  # This file
├── LICENSE                    # MIT
├── assets/                    # README assets
│   └── banner.svg             # Terminal-style banner in Anthropic colors
├── contexts/                  # Mode profiles
│   ├── dev.md
│   ├── orchestrate.md
│   ├── review.md
│   └── research.md
├── bin/                       # Automation scripts
│   ├── claude-aliases.sh      # Mode aliases + pipeline functions
│   ├── claude-loop.sh         # Continuous loop with quality gates
│   └── claude-session-save.sh # Cross-session memory persistence
├── instincts/                 # Learned patterns with confidence scores
│   ├── parallel-agents-for-independent-files.md
│   ├── de-sloppify-separate-pass.md
│   ├── dual-review-catches-more.md
│   └── uuid-esm-incompatibility-jest.md
├── config/                    # Settings templates
│   ├── env-settings.json      # Agent Teams, cost tracking, hook profile
│   └── observer-config.json   # Continuous learning observer config
├── reference/                 # Documentation
│   └── ORCHESTRATION-REFERENCE.md
└── video/                     # Remotion source for feature video
    ├── index.ts
    ├── Root.tsx
    └── scenes/
        └── FeatureVideo.tsx
```

## Uninstall

```bash
bash uninstall.sh           # Interactive removal
bash uninstall.sh --dry-run # Preview what would be removed
```

The uninstaller only removes files it installed. It never touches ECC hooks, plugins, session data, user-created instincts, or user-modified settings. Env settings are only reverted if their values still match what was installed (user modifications are preserved).

## Key Slash Commands

After installation, these slash commands become available in Claude Code:

| Command | Purpose |
|---------|---------|
| `/plan` | Plan before coding (wait for confirmation) |
| `/tdd` | Test-driven development workflow |
| `/verify` | Full verification loop (build + lint + test + security) |
| `/code-review` | Comprehensive quality review |
| `/santa-loop` | Dual-model adversarial review (both must approve) |
| `/team-builder` | Compose and dispatch agent teams |
| `/learn` | Extract reusable patterns from current session |
| `/instinct-status` | View all learned instincts with confidence |
| `/save-session` | Persist session state for later resumption |
| `/resume-session` | Load previous session and continue |
| `/promote` | Move project instincts to global scope |
| `/evolve` | Cluster instincts into skills/agents |
| `/security-scan` | Scan configuration for vulnerabilities |

## Contributing

Contributions welcome. If you've discovered patterns that make Claude Code more effective, consider adding them as instincts with evidence and confidence scores.

## License

[MIT](LICENSE)
