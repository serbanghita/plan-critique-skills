# Plan & Critique Skills for Claude Code

Iterative, adversarial plan review and execution skills for Claude Code.

---

## Install

### Option 1: Marketplace install (recommended)

Add the marketplace and install the plugin from within Claude Code:

```
/plugin marketplace add serbanghita/plan-critique-skills
/plugin install plan@serbanghita
```

Installed as a plugin, skills are namespaced under the `plan` plugin name:
- `/plan:create`
- `/plan:critique`
- `/plan:cycle`
- `/plan:execute`
- `/plan:archive`

### Option 2: Manual install

Clone the repository and copy the skills and working agreement to `.claude/`:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p .claude/skills && \
cp -r plan-critique-skills/skills/* .claude/skills/ && \
cp plan-critique-skills/working-agreement.md .claude/ && \
rm -rf plan-critique-skills
```

Installed manually, the skills are invoked without a namespace:
- `/create`
- `/critique`
- `/cycle`
- `/execute`
- `/archive`

---

## Configuration

Settings are stored in `.claude/plan-critique-config.json`:

```json
{
  "plansFolder": ".planning",
  "cycleIterations": 3
}
```

- If `plansFolder` is not set, `/plan:create` prompts for the location (default: `.planning`).
- `cycleIterations` is optional and only read by `/plan:cycle`. It caps the critique and merge iterations of one
  run. Default `3`, valid range 1 to 5.
- Project standards are read from `CLAUDE.md` in the project root.
- Standing rules are read from `working-agreement.md` located in the plugin root or `.claude/`.

---

## Usage Workflow

1. Create a plan:
   ```
   /plan:create "Add User Authentication"
   ```
   This creates `.planning/add-user-authentication/plan.md`.

2. Edit the plan:
   Fill in requirements, affected files, implementation steps, and verification approach.

3. Critique the plan:
   ```
   /plan:critique
   ```
   Claude performs an adversarial review and writes `.planning/add-user-authentication/critique.md`.

4. Iterate:
   Update `plan.md` based on critique findings and run `/plan:critique` again until satisfied.

5. Execute the plan:
   ```
   /plan:execute
   ```
   Executes each chapter step by step with verification and state tracking.

6. Archive the plan:
   ```
   /plan:archive
   ```
   Moves completed plan to `.planning/archived/add-user-authentication/`.

---

## One-pass cycle

`/plan:cycle` runs steps 1 to 4 of the workflow above in a single pass and stops before execution:

```
/plan:cycle "Add User Authentication"
```

- Creates the plan folder when the name does not match an existing plan.
- Drafts `plan.md` only when it is empty or still the unedited template. A plan you wrote is never overwritten.
- Critiques and merges up to `cycleIterations` times, stopping early when an iteration finds nothing new.
- Merges on its own only what is obvious. Anything ambiguous, anything that touches what you wrote, and
  anything that changes the scope of a chapter is put to you as a question before it is written.
- Records every merged finding, every question and its answer, and every skipped finding in `cycle-log.md`,
  then stops and waits for your approval.

It never executes the plan. Run `/plan:execute` yourself once the plan looks right.

---

## Parallel Plans and Session Tracking

Each terminal session tracks its own active plan using the Claude Code process ID (`$PPID`):
- Session state is saved in `.planning/.sessions/[PID]`.
- When running `/plan:critique` or `/plan:execute`, your session plan is auto-selected.
- Stale session files from closed processes are cleaned up automatically via `kill -0 [PID]` checks.
- Add `.planning/.sessions/` to `.gitignore`.
