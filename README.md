# plan-critique-skills
> Plan -> Critique (iterate) -> Execute -> Archive

Iterative plan review and execution workflow for Claude Code, Agy (Gemini CLI), and GitHub Copilot CLI.
They enable you to work with multiple written plans while keeping full control of the feedback loop from the LLM.

---

## Agent Guides

For detailed agent-specific setup, configuration, and workflows:
- [Claude Code Guide](docs/claude-code.md)
- [Agy (Gemini CLI / Antigravity) Guide](docs/agy.md)
- [GitHub Copilot CLI Guide](docs/copilot.md)

---

## Install

### Claude Code

Add the marketplace and install the plugin from within Claude Code:

```
/plugin marketplace add serbanghita/plan-critique-skills
/plugin install plan@serbanghita
```

Installed as a plugin, skills are namespaced under `plan`:
`/plan:create`, `/plan:critique`, `/plan:execute`, `/plan:archive`.

Manual install via git clone:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p .claude/skills && \
cp -r plan-critique-skills/skills/* .claude/skills/ && \
cp plan-critique-skills/working-agreement.md .claude/ && \
rm -rf plan-critique-skills
```

Manual install skills are invoked bare: `/create`, `/critique`, `/execute`, `/archive`.

See the [Claude Code Guide](docs/claude-code.md) for full configuration details.

### Agy (Gemini CLI / Antigravity)

Workspace installation (recommended):

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p .gemini/skills && \
cp -r plan-critique-skills/.gemini/skills/* .gemini/skills/ && \
cp plan-critique-skills/working-agreement.md .gemini/ && \
rm -rf plan-critique-skills
```

Global installation (available in all workspaces):

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p ~/.gemini/config/skills && \
cp -r plan-critique-skills/.gemini/skills/* ~/.gemini/config/skills/ && \
rm -rf plan-critique-skills
```

Agy skills carry the `plan-` prefix:
`/plan-create`, `/plan-critique`, `/plan-execute`, `/plan-archive`.

See the [Agy Guide](docs/agy.md) for full configuration details.

### GitHub Copilot CLI

Add the marketplace and install the plugin from your terminal:

```bash
copilot plugin marketplace add serbanghita/plan-critique-skills
copilot plugin install plan@serbanghita
```

The same commands work from within an active session as `/plugin marketplace add ...` and `/plugin install ...`.

Manual install via git clone:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p .github/skills && \
cp -r plan-critique-skills/.github/skills/* .github/skills/ && \
cp plan-critique-skills/working-agreement.md . && \
rm -rf plan-critique-skills
```

Copilot skills carry the `plan-` prefix:
`/plan-create`, `/plan-critique`, `/plan-execute`, `/plan-archive`.

Verify with `copilot skill list`, and reload during a session with `/skills reload`.

See the [GitHub Copilot CLI Guide](docs/copilot.md) for full configuration details.

---

## Agent Compatibility Matrix

| Feature | Claude Code | Agy (Gemini CLI) | GitHub Copilot CLI |
| :--- | :--- | :--- | :--- |
| **Plugin Skill Names** | `/plan:create`, `/plan:critique`, `/plan:execute`, `/plan:archive` | `/plan-create`, `/plan-critique`, `/plan-execute`, `/plan-archive` | `/plan-create`, `/plan-critique`, `/plan-execute`, `/plan-archive` |
| **Manual Skill Names** | `/create`, `/critique`, `/execute`, `/archive` | `/plan-create`, `/plan-critique`, `/plan-execute`, `/plan-archive` | `/plan-create`, `/plan-critique`, `/plan-execute`, `/plan-archive` |
| **Skill Storage** | `skills/` or `.claude/skills/` | `.gemini/skills/` or `~/.gemini/config/skills/` | `.github/skills/` |
| **Config File** | `.claude/plan-critique-config.json` | `.gemini/plan-critique-config.json` (fallback `.claude/`) | `.copilot/plan-critique-config.json` (fallback `.claude/`) |
| **Session Key** | `$PPID` (process ID) | `$PPID` (process ID) | `COPILOT_AGENT_SESSION_ID` |
| **Project Standards** | `CLAUDE.md` | `GEMINI.md`, `AGENTS.md`, `CLAUDE.md` | `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md` |

---

## How it works

```
create ──► edit 'plan.md' ──► critique ──► read 'critique.md', update 'plan.md'
                 ▲                                     │
                 └──────── iterate until satisfied ────┘
                                   │
                                   ▼
                                execute ──► archive
```

The flow is identical across all agents:
1. Create a plan folder with a structured `plan.md` template.
2. Edit `plan.md` with requirements, affected files, and verification steps.
3. Run critique to perform an adversarial review and produce `critique.md`.
4. Review findings, adjust `plan.md`, and re-critique until satisfied.
5. Execute the plan step by step with verification.
6. Archive the completed plan.

---

## Usage

### Pre-requisites

- One of the supported coding agent CLIs installed:
  - [Claude Code](https://claude.ai/claude-code) CLI
  - [Agy / Gemini CLI / Antigravity](https://github.com/google-gemini)
  - [GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- A project standards file in your project root (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, or `.github/copilot-instructions.md`).

### Skills Overview

| Skill | Purpose | What it does |
| :--- | :--- | :--- |
| **create** | Initialize | Create a new plan directory in `[plansFolder]/[plan name]/plan.md`. |
| **critique** | Review | Adversarial review of the plan. Produces `critique.md` with verified evidence. |
| **execute** | Implementation | Parse the plan into steps, confirm, and execute each step with verification. |
| **archive** | Finalize | Move completed plan to `[plansFolder]/archived/` and clean up. |

### Working agreement

`working-agreement.md` holds standing rules that bind the create, critique, and execute phases. They are read at
the start of each run and override any conflicting instruction inside the skill:

- Critique is adversarial: Every finding carries a confidence grade (`CONFIRMED` or `UNVERIFIED`) and proof.
- Execution is tests-first where the project has a test suite.
- Every plan chapter must state affected files and verification steps.
- Output style: brief, plain English, no emojis, no em dashes, no truncated code.
- Git: no co-author trailers (`Co-Authored-By`), commit only when requested.

Edit `working-agreement.md` to customize rules for your team.

### Parallel Plans

You can work on multiple plans simultaneously in separate terminals. Each session tracks its own current plan via
session files in `.planning/.sessions/`:
- Claude Code and Agy key session files by process ID (`$PPID`).
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
  - Create: ~1.3k tokens
  - Critique: ~3.1k tokens
  - Execute: ~4.8k tokens
  - Archive: ~1.3k tokens
- `working-agreement.md`: Adds ~700 tokens on invoke to create, critique, and execute runs.

---

## Credits

Created by [Serban Ghita](https://github.com/serbanghita) under MIT License.
