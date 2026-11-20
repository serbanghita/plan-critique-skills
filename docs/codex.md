# Plan & Critique Skills for Codex

Iterative plan review and execution skills for Codex.

---

## Install

Clone the repository to a permanent location:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git ~/work/plan-critique-skills
```

### Global install

Link each skill directory into `~/.agents/skills/`:

```bash
mkdir -p ~/.agents/skills
for skill in ~/work/plan-critique-skills/skills/*; do
  ln -s "$skill" ~/.agents/skills/"$(basename "$skill")"
done
```

### Per-project install

Link the skill directories into `.agents/skills/` in the project where you want to use them:

```bash
mkdir -p .agents/skills
for skill in ~/work/plan-critique-skills/skills/*; do
  ln -s "$skill" .agents/skills/"$(basename "$skill")"
done
```

Start a new Codex session after installing or updating the skills. Updates are available after pulling the clone:

```bash
git -C ~/work/plan-critique-skills pull
```

Codex discovers the skill directories from `~/.agents/skills/` or the current repository's `.agents/skills/`.
The skill files and their adjacent references stay together in the canonical `skills/` tree.

---

## Available skills

- `$plan-create` - Create a plan folder with a `plan.md` template
- `$plan-critique` - Adversarially review a plan and write `critique.md`
- `$plan-cycle` - Draft, critique and merge in one loop, then stop for approval
- `$plan-execute` - Execute a plan step by step with verification and progress tracking
- `$plan-archive` - Move a completed plan to the archive

---

## Configuration

Codex settings are stored in `.codex/plan-critique-config.json`. Existing config files in `.claude/`, `.gemini/`,
or `.copilot/` are read as fallbacks:

```json
{
  "plansFolder": ".planning",
  "cycleIterations": 3
}
```

If `plansFolder` is unset, `$plan-create` asks where to store plans (default `.planning`) and writes the setting to
`.codex/plan-critique-config.json`. `cycleIterations` is optional and only read by `$plan-cycle`; it defaults to 3
and accepts values from 1 to 5.

Codex reads `AGENTS.md` for project instructions. The skills use the process ID (`$PPID`) to track the current plan
for a session.

---

## Workflow

1. Run `$plan-create "Implement Caching"` to create `.planning/implement-caching/plan.md`.
2. Fill in the requirements, affected files, steps and verification commands.
3. Run `$plan-critique` to review the plan against the codebase.
4. Update the plan and repeat the critique until satisfied.
5. Run `$plan-execute` to work through the approved plan.
6. Run `$plan-archive` to archive the completed plan.

`$plan-cycle` combines plan drafting and critique, merges clear findings and stops for your approval. It never
executes the plan.
