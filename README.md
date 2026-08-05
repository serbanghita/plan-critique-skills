# claude-code-plan-critique
> Plan → Critique (iterate) → Execute → Archive

Claude Code and GitHub Copilot CLI skills for iterative plan review and execution. They enable you to work with
multiple written plans while keeping full control of the feedback-loop from the LLM.

## Install

### Claude Code

Add the marketplace and install the plugin from within Claude Code:

```
/plugin marketplace add serbanghita/claude-code-plan-critique
/plugin install plan@serbanghita
```

Installed as a plugin, the skills are namespaced under the plugin name `plan`:
`/plan:create`, `/plan:critique`, `/plan:execute`, `/plan:archive`.

### GitHub Copilot CLI

Add the marketplace and install the plugin from your terminal:

```
copilot plugin marketplace add serbanghita/claude-code-plan-critique
copilot plugin install plan@serbanghita
```

The same commands work from within a session as `/plugin marketplace add ...` and `/plugin install ...`.

Copilot CLI does not namespace skills, so they carry the `plan-` prefix in their own name:
`/plan-create`, `/plan-critique`, `/plan-execute`, `/plan-archive`.

Verify the install with `copilot skill list`, and reload after a change with `/skills reload`.

## How it works

```
/plan:create ──► edit 'plan.md' ──► /plan:critique ──► read 'critique.md', update 'plan.md'
                      ▲                                     │
                      └──────── iterate until satisfied ────┘
                                        │
                                        ▼
                              /plan:execute ──► /plan:archive
```

The diagram uses the Claude Code names. On Copilot CLI read them as `/plan-create`, `/plan-critique`,
`/plan-execute` and `/plan-archive`.

## Usage

### Pre-requisites

- [Claude Code](https://claude.ai/claude-code) CLI or
  [GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/use-copilot-agents/use-copilot-cli) installed
- A project standards file in your project root. Claude Code reads `CLAUDE.md`. Copilot CLI reads
  `.github/copilot-instructions.md`, `AGENTS.md` or `CLAUDE.md`.

### Skills

| Claude Code      | Copilot CLI      | What it does                                                                 |
| ---------------- | ---------------- | ---------------------------------------------------------------------------- |
| `/plan:create`   | `/plan-create`   | Create a new plan in `.planning/[plan name]/plan.md`. Accepts the plan name.  |
| `/plan:critique` | `/plan-critique` | Review the plan. Generates a `critique.md` with issues and suggestions.       |
| `/plan:execute`  | `/plan-execute`  | Parse the plan into steps, confirm, then run each step. Resumes on failure.   |
| `/plan:archive`  | `/plan-archive`  | Move a completed plan to `.planning/archived/` and delete the original.       |

The loop is: create, edit `plan.md`, critique, decide which parts of the critique are good for the plan and
update `plan.md`, critique again, then execute and archive.

### Working agreement

`working-agreement.md` holds standing rules that bind the create, critique and execute phases. They are read at
the start of each run and override any conflicting instruction inside the skill. In short:

- Critique is adversarial. Every finding carries a confidence grade and a `file:line` or command-output proof.
  Anything that could not be verified is labelled UNVERIFIED rather than stated as fact.
- Execution is tests-first where the project has a test suite. A step is not COMPLETED until the suite passes,
  and a project without tests gets its steps reported as unverified rather than done.
- Every plan chapter must name its affected files and how success is verified. Critique flags the ones that do
  not.
- No emojis, no em dashes, no truncated code, and no `Co-Authored-By` trailers on commits.

Edit the file to suit your team. It is the single place the rules live, so a change there applies to all three
phases at once.

### Parallel Plans

You can work on multiple plans simultaneously in separate terminals. Each session tracks its own current plan via
session files in `.planning/.sessions/`. Claude Code keys them by process id, Copilot CLI keys them by the
`COPILOT_AGENT_SESSION_ID` of the running session.

Example workflow with two terminals:

```
Terminal 1                          Terminal 2
──────────────────────────────────  ──────────────────────────────────
/plan:create "Add Authentication"   /plan:create "Fix Database Bug"
edit plan.md                        edit plan.md
/plan:critique                      /plan:critique
...                                 ...
```

Each terminal remembers which plan it's working on. When you run the critique or execute skill, your session's
plan is marked as "(current session)" in the selection list.

Add `.planning/.sessions/` to your `.gitignore` - these are local session files that should not be committed.

## How is this different from built-in plan mode?

Claude Code has a built-in plan mode where Claude writes the plan and you approve or reject it.  
This plugin inverts that: you write the plan, Claude critiques it, and you decide which feedback
to accept. The critique loop can run as many times as you want.

It is slower by design. You read each critique, cherry-pick changes, and iterate until the plan
is yours, not Claude's interpretation of what you asked for. This is micro-management on purpose.

Plan mode is great when you trust Claude to drive. This plugin is for when you want to drive and
use Claude as a reviewer. The plans are persistent files you own, they can be archived for future
reference, and you can work on multiple plans in parallel across terminals.

See [ghita.org/blog/claude-code-plan-critique](https://ghita.org/blog/claude-code-plan-critique/) for a better explanation.

## Costs

Token cost of the skills for v2.2.0, as reported by `claude plugin details plan@serbanghita`.
Always-on is the fixed cost added to every session just for having the plugin enabled (the skill
descriptions). On-invoke is paid only when a skill runs, when its `SKILL.md` body loads; the linked
format files load on demand within a skill. Numbers are rounded estimates, not exact billing
(`1k` is about 1000 tokens).

| Skill    | Always-on | On-invoke |
| -------- | --------- | --------- |
| create   | ~20       | ~1.3k     |
| critique | <20       | ~3.1k     |
| execute  | ~30       | ~4.8k     |
| archive  | ~30       | ~1.3k     |

Always-on total: ~90 tokens added to every session. On-invoke cost is paid each time that skill
fires, so one full plan -> critique -> execute -> archive cycle pays each skill's on-invoke cost once.

The create, critique and execute skills each read `working-agreement.md` when they run. That is a
linked file, so it is not counted in the on-invoke figures above. It adds roughly 700 tokens to each
of those three runs. Trimming rules you do not use is the cheapest way to bring that down.

## Contribute

Clone the repository and copy the skills to your project.

Claude Code:

```bash
git clone https://github.com/serbanghita/claude-code-plan-critique.git && \
mkdir -p .claude/skills && \
cp -r claude-code-plan-critique/skills/* .claude/skills/ && \
cp claude-code-plan-critique/working-agreement.md .claude/ && \
rm -rf claude-code-plan-critique
```

The `working-agreement.md` copy is required. The skills read it as `../../working-agreement.md`, which resolves
to the plugin root for a marketplace install and to `.claude/` for a manual one.

Installed manually, the skills are invoked without a namespace:
`/create`, `/critique`, `/execute`, `/archive`. These bare names are generic, so prefer the
marketplace install if you run other skills with the same names.

If you upgraded from a previous manual install, delete the old `.claude/commands/plan-*.md` files.

GitHub Copilot CLI:

```bash
git clone https://github.com/serbanghita/claude-code-plan-critique.git && \
mkdir -p .github/skills && \
cp -r claude-code-plan-critique/.github/skills/* .github/skills/ && \
cp claude-code-plan-critique/working-agreement.md . && \
rm -rf claude-code-plan-critique
```

The Copilot skills read the working agreement as `../../../working-agreement.md`, which resolves to the plugin
root for a marketplace install and to the project root for a manual one. The skill names already carry the
`plan-` prefix, so a manual install is invoked the same way as a plugin install.

If the CLI is already running, restart it or run `/skills reload` to load the new skills.

## Credits

Created by [Serban Ghita](https://github.com/serbanghita) under MIT License
