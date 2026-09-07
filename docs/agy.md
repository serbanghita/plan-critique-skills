# Plan & Critique Skills for Agy (Gemini CLI / Antigravity)

Iterative, adversarial plan review and execution skills for Agy (Gemini CLI) and Antigravity.

---

## Install

### Option 1: Workspace installation (recommended)

Install the skills directly in your project repository under `.gemini/skills/`:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p .gemini/skills && \
cp -r plan-critique-skills/.gemini/skills/* .gemini/skills/ && \
cp plan-critique-skills/working-agreement.md .gemini/ && \
rm -rf plan-critique-skills
```

### Option 2: Global installation

Install the skills globally so they are available in every project workspace:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p ~/.gemini/config/skills && \
cp -r plan-critique-skills/.gemini/skills/* ~/.gemini/config/skills/ && \
rm -rf plan-critique-skills
```

---

## Available Skills

The skills carry the `plan-` prefix:
- `/plan-create` - Create a new plan folder with `plan.md` template
- `/plan-critique` - Adversarial review of `plan.md`, generating `critique.md`
- `/plan-cycle` - Draft, critique and merge in one loop, then stop for approval
- `/plan-execute` - Step-by-step verified execution with progress tracking
- `/plan-archive` - Move completed plan to `.planning/archived/`

---

## Configuration

Settings are stored in `.gemini/plan-critique-config.json` with fallback to `.claude/plan-critique-config.json`:

```json
{
  "plansFolder": ".planning",
  "cycleIterations": 3
}
```

- If `plansFolder` is not set, `/plan-create` prompts for the location (default: `.planning`).
- `cycleIterations` is optional and only read by `/plan-cycle`. It caps the critique and merge iterations of one
  run. Default `3`, valid range 1 to 5.
- Project standards are read from `GEMINI.md`, `AGENTS.md`, or `CLAUDE.md` in the project root.
- Standing rules are read from `working-agreement.md` located in `.gemini/` or the project root.

---

## Usage Workflow

1. Create a plan:
   ```
   /plan-create "Refactor Storage Layer"
   ```
   This creates `.planning/refactor-storage-layer/plan.md`.

2. Edit the plan:
   Fill in objectives, affected files, implementation phases, and test verification approach.

3. Critique the plan:
   ```
   /plan-critique
   ```
   Agy performs an adversarial critique and writes `.planning/refactor-storage-layer/critique.md`.

4. Iterate:
   Refine `plan.md` addressing identified issues and run `/plan-critique` again until satisfied.

5. Execute the plan:
   ```
   /plan-execute
   ```
   Agy executes each chapter with test-driven verification.

6. Archive the plan:
   ```
   /plan-archive
   ```
   Moves completed plan to `.planning/archived/refactor-storage-layer/`.

---

## One-pass cycle

`/plan-cycle` runs steps 1 to 4 of the workflow above in a single pass and stops before execution:

```
/plan-cycle "Refactor Storage Layer"
```

- Creates the plan folder when the name does not match an existing plan.
- Drafts `plan.md` only when it is empty or still the unedited template. A plan you wrote is never overwritten.
- Critiques and merges up to `cycleIterations` times, stopping early when an iteration finds nothing new.
- Merges on its own only what is obvious. Anything ambiguous, anything that touches what you wrote, and
  anything that changes the scope of a chapter is put to you as a question before it is written.
- Records every merged finding, every question and its answer, and every skipped finding in `cycle-log.md`,
  then stops and waits for your approval.

It never executes the plan. Run `/plan-execute` yourself once the plan looks right.

---

## Parallel Plans and Session Tracking

Each terminal session tracks its own active plan using the process ID (`$PPID`):
- Session state is saved in `.planning/.sessions/[PID]`.
- When running `/plan-critique` or `/plan-execute`, your session plan is auto-selected.
- Stale session files from closed processes are cleaned up automatically via `kill -0 [PID]` checks.
- Add `.planning/.sessions/` to `.gitignore`.
