# Plan & Critique Skills for GitHub Copilot CLI

Iterative, adversarial plan review and execution skills for GitHub Copilot CLI.

---

## Install

Clone the repository to a permanent location:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git ~/work/plan-critique-skills
```

### Option 1: Global load (recommended)

Choose ONE of these global methods (do not use both, to avoid duplicate skill registration):

Symlink each skill into `~/.agents/skills/`:

```bash
mkdir -p ~/.agents/skills && ln -s ~/work/plan-critique-skills/skills/* ~/.agents/skills/
```

Or add the `skills/` directory directly inside an active Copilot session:

```
/skills add ~/work/plan-critique-skills/skills
```

To update, pull the clone and reload skills in the active Copilot session:

```bash
git -C ~/work/plan-critique-skills pull
```

```
/skills reload
```

Verify loaded skills:

```bash
copilot skill list
```

### Option 2: Per-project linked checkout

Link the repository's `skills/` folder into a single project. This expects `.github/skills` not to already exist:

```bash
mkdir -p .github && ln -s ~/work/plan-critique-skills/skills .github/skills
```

### Option 3: Marketplace install

Add the marketplace and install the plugin from your terminal:

```bash
copilot plugin marketplace add serbanghita/plan-critique-skills
copilot plugin install plan@serbanghita
```

Or from within an active Copilot session:

```
/plugin marketplace add serbanghita/plan-critique-skills
/plugin install plan@serbanghita
```

---

## Available Skills

- `/plan-create` - Create a new plan folder with `plan.md` template
- `/plan-critique` - Adversarial review of `plan.md`, generating `critique.md`
- `/plan-cycle` - Draft, critique and merge in one loop, then stop for approval
- `/plan-execute` - Step-by-step verified execution with progress tracking
- `/plan-archive` - Move completed plan to `.planning/archived/`

---

## Configuration

Settings are stored in `.copilot/plan-critique-config.json` with read fallback to `.claude/plan-critique-config.json`
and `.gemini/plan-critique-config.json`:

```json
{
  "plansFolder": ".planning",
  "cycleIterations": 3
}
```

- If `plansFolder` is not set, `/plan-create` prompts for the location (default: `.planning`) and saves it to
  `.copilot/plan-critique-config.json`.
- `cycleIterations` is optional and only read by `/plan-cycle`. It caps the critique and merge iterations of one
  run. Default `3`, valid range 1 to 5.
- Project standards are resolved from `.github/copilot-instructions.md` first, falling back to `AGENTS.md` then
  `CLAUDE.md`.
- Standing rules are read from `skills/plan-create/working-agreement.md` (included inside the `plan-create` skill
  folder).

---

## Usage Workflow

1. Create a plan:
   ```
   /plan-create "Implement Caching"
   ```
   This creates `.planning/implement-caching/plan.md`.

2. Edit the plan:
   Fill in requirements, affected files, execution steps, and verification commands.

3. Critique the plan:
   ```
   /plan-critique
   ```
   Copilot performs an adversarial critique and writes `.planning/implement-caching/critique.md`.

4. Iterate:
   Update `plan.md` based on critique findings and run `/plan-critique` again until satisfied.

5. Execute the plan:
   ```
   /plan-execute
   ```
   Executes each chapter step by step with verification and state tracking.

6. Archive the plan:
   ```
   /plan-archive
   ```
   Moves completed plan to `.planning/archived/implement-caching/`.

---

## One-pass cycle

`/plan-cycle` runs steps 1 to 4 of the workflow above in a single pass and stops before execution:

```
/plan-cycle "Implement Caching"
```

- Creates the plan folder when the name does not match an existing plan.
- Drafts `plan.md` only when it is empty or still the unedited template. A plan you wrote is never overwritten.
- Critiques and merges up to `cycleIterations` times, stopping early on a clean first pass or after two consecutive
  clean passes following a merge (after a merge in a run, two clean iterations are needed, so a run merging in
  iteration 1 has its earliest stop at iteration 3; `cycleIterations` of 1 or 2 hits the iteration limit unless a
  prior run left `cleanPasses = 1`, and 4 or 5 is needed to stop before the cap).
- Merges on its own only what is obvious. Anything ambiguous, anything that touches what you wrote, and
  anything that changes the scope of a chapter is put to you as a question before it is written.
- Records every merged finding, every question and its answer, and every skipped finding in `cycle-log.md`,
  then stops and waits for your approval.

It never executes the plan. Run `/plan-execute` yourself once the plan looks right.

---

## Parallel Plans and Session Tracking

Each Copilot session tracks its active plan using the `COPILOT_AGENT_SESSION_ID` environment variable:
- Session state is saved in `.planning/.sessions/[SESSION_ID]`.
- When running `/plan-critique` or `/plan-execute`, your session plan is auto-selected.
- Non-PID session files older than 7 days are cleaned up automatically without process-killing shell dependencies
  (Windows compatible).
- Add `.planning/.sessions/` to `.gitignore`.
