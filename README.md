# plan-critique-skills
> Plan -> Critique (iterate) -> Execute -> Archive

Iterative plan review and execution workflow for Codex, Claude Code, Agy (Gemini CLI / Antigravity), and GitHub
Copilot CLI. Work with multiple written plans while keeping full control of the feedback loop from the LLM.

---

## Install

Clone once to a permanent location; each agent loads directly from `skills/` with no copy-paste:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git ~/work/plan-critique-skills
```

Pick one global load method for your agent:

- **Codex:** symlink each skill into `~/.agents/skills/`:
  ```bash
  mkdir -p ~/.agents/skills && ln -s ~/work/plan-critique-skills/skills/* ~/.agents/skills/
  ```

- **Claude Code:** symlink each skill into `~/.claude/skills/`:
  ```bash
  mkdir -p ~/.claude/skills && ln -s ~/work/plan-critique-skills/skills/* ~/.claude/skills/
  ```
- **Agy (Gemini CLI / Antigravity):** either symlink into `~/.agents/skills/` or register in `~/.gemini/config/skills.json`:
  ```bash
  mkdir -p ~/.agents/skills && ln -s ~/work/plan-critique-skills/skills/* ~/.agents/skills/
  ```
  ```json
  // ~/.gemini/config/skills.json
  { "entries": [{ "path": "~/work/plan-critique-skills/skills" }] }
  ```
- **GitHub Copilot CLI:** either symlink into `~/.agents/skills/` (same `ln -s` command above) or run inside Copilot:
  ```
  /skills add ~/work/plan-critique-skills/skills
  ```

### Updating

Pull the clone and reload skills without re-copying anything:

```bash
git -C ~/work/plan-critique-skills pull
```

- **Codex:** start a new Codex session to pick up updated skills.
- **Agy / Gemini CLI & GitHub Copilot CLI:** run `/skills reload` in your active session.
- **Claude Code:** restart your session to pick up updated directory skills (or run `/reload-plugins` for Marketplace installs).

Per-project linking and Marketplace/Plugin setup live in the agent guides:
- [Claude Code Guide](docs/claude-code.md)
- [Codex Guide](docs/codex.md)
- [Agy (Gemini CLI / Antigravity) Guide](docs/agy.md)
- [GitHub Copilot CLI Guide](docs/copilot.md)

---

## Agent Compatibility Matrix

| Feature | Codex | Claude Code | Agy (Gemini CLI) | GitHub Copilot CLI |
| :--- | :--- | :--- | :--- | :--- |
| **Linked / Manual Names** | `$plan-create`, `$plan-critique`, `$plan-cycle`, `$plan-execute`, `$plan-archive` | `/plan-create`, `/plan-critique`, `/plan-cycle`, `/plan-execute`, `/plan-archive` | `/plan-create`, `/plan-critique`, `/plan-cycle`, `/plan-execute`, `/plan-archive` | `/plan-create`, `/plan-critique`, `/plan-cycle`, `/plan-execute`, `/plan-archive` |
| **Plugin Skill Names** | N/A | `/plan:plan-create`, `/plan:plan-critique`, `/plan:plan-cycle`, `/plan:plan-execute`, `/plan:plan-archive` | N/A | `/plan-create`, `/plan-critique`, `/plan-cycle`, `/plan-execute`, `/plan-archive` |
| **Skill Storage** | `~/.agents/skills/` or `.agents/skills/` | `~/.claude/skills/` or `.claude/skills/` | `~/.agents/skills/` or `skills.json` | `~/.agents/skills/`, `/skills add`, or `.github/skills/` |
| **Config File** | `.codex/plan-critique-config.json`, then shared fallback | `.claude/` first, cross-fallback | `.gemini/` first, cross-fallback | `.copilot/` first, cross-fallback |
| **Session Key** | `$PPID` (process ID) | `$PPID` (process ID) | `$PPID` (process ID) | `COPILOT_AGENT_SESSION_ID` (fallback `default`) |
| **Project Standards** | `AGENTS.md` | `CLAUDE.md` -> `AGENTS.md` | `GEMINI.md` -> `AGENTS.md` -> `CLAUDE.md` | `.github/copilot-instructions.md` -> `AGENTS.md` -> `CLAUDE.md` |

---

## How it works

```
plan-create ──► edit 'plan.md' ──► plan-critique ──► read 'critique.md', update 'plan.md'
                     ▲                                           │
                     └──────── iterate until satisfied ──────────┘
                                         │
                                         ▼
                                   plan-execute ──► plan-archive
```

The flow is identical across all agents:
1. Create a plan folder with a structured `plan.md` template.
2. Edit `plan.md` with requirements, affected files, and verification steps.
3. Run `plan-critique` to perform an adversarial review and produce `critique.md`.
4. Review findings, adjust `plan.md`, and re-critique until satisfied.
5. Execute the plan step by step with verification.
6. Archive the completed plan.

Steps 1 to 4 can also be run in one pass with `plan-cycle`, which drafts `plan.md` only when you have not written
one, then critiques and merges up to three times and stops for your approval before anything is executed. It merges
only the obvious changes on its own and asks you about the rest.

---

## Usage

### Pre-requisites

- One of the supported coding agent CLIs installed:
  - [Claude Code](https://claude.ai/claude-code) CLI
  - [Codex](https://openai.com/codex/) CLI or app
  - [Agy / Gemini CLI / Antigravity](https://github.com/google-gemini)
  - [GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- A project instructions file in your project root (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or `.github/copilot-instructions.md`).

### Skills Overview

| Skill | Purpose | What it does |
| :--- | :--- | :--- |
| **plan-create** | Initialize | Create a new plan directory in `[plansFolder]/[plan name]/plan.md`. |
| **plan-critique** | Review | Adversarial review of the plan. Produces `critique.md` with verified evidence and 1-10 grades. |
| **plan-cycle** | Loop | Draft (only if needed), critique and merge up to `cycleIterations` times, asking before any non-obvious change, then stop for approval. |
| **plan-execute** | Implementation | Parse the plan into steps, confirm, and execute each step with verification. |
| **plan-archive** | Finalize | Move completed plan to `[plansFolder]/archived/` and clean up. |

### Working agreement

`skills/plan-create/working-agreement.md` holds standing rules that bind the `plan-create`, `plan-critique`,
`plan-cycle`, and `plan-execute` phases. They are read at the start of each run and override any conflicting
instruction inside the skill:

- Critique is adversarial: every finding carries a confidence grade (`CONFIRMED` or `UNVERIFIED`), 1-10 ratings, and proof.
- Execution is tests-first where the project has a test suite.
- Every plan chapter must state affected files and verification steps.
- Changes to the plan are never assumed: anything not obvious is put to you as a question first.
- Output style: brief, plain English, no emojis, no em dashes, no truncated code.
- Git: no co-author trailers (`Co-Authored-By`), commit only when requested.

Edit `skills/plan-create/working-agreement.md` to customize rules for your team.

### Parallel Plans

You can work on multiple plans simultaneously in separate terminals. Each session tracks its own current plan via
session files in `.planning/.sessions/`:
- Codex, Claude Code and Agy key session files by process ID (`$PPID`).
- GitHub Copilot CLI keys session files by `COPILOT_AGENT_SESSION_ID`.

Each terminal auto-selects its active plan when running critique or execute skills.

Add `.planning/.sessions/` to your `.gitignore`.

---

## How is this different from built-in plan mode?

Many AI coding tools offer built-in plan modes where the LLM writes the plan and you approve or reject it.

This workflow inverts that model:
- You write and own the plan.
- The AI acts as an adversarial reviewer checking feasibility, types, file existence, and edge cases.
- You decide which critique findings to incorporate.
- Plans remain persistent markdown files in your repository that can be executed and archived.

See [ghita.org/blog/claude-code-plan-critique](https://ghita.org/blog/claude-code-plan-critique/) for background.

---

## Costs

Token cost estimates for skills:
- Always-on overhead: ~90 tokens added per session for skill descriptions.
- On-invoke cost: Paid when a skill executes (`SKILL.md` body loads).
  - `plan-create`: ~1.3k tokens
  - `plan-critique`: ~3.1k tokens
  - `plan-cycle`: ~3.3k tokens for the skill body, plus one critique pass per iteration
  - `plan-execute`: ~4.8k tokens
  - `plan-archive`: ~1.3k tokens
- `skills/plan-create/working-agreement.md`: Adds ~700 tokens on invoke to `plan-create`, `plan-critique`,
  `plan-cycle`, and `plan-execute` runs.

---

## Credits

Created by [Serban Ghita](https://github.com/serbanghita) under MIT License.
