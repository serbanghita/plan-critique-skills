# Plan & Critique Skills for Claude Code

Iterative, adversarial plan review and execution skills for Claude Code.

---

## Install

Clone the repository once to a permanent location (no copy-paste required):

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git ~/work/plan-critique-skills
```

### Option 1: Global symlink install (recommended)

Link each skill directory into `~/.claude/skills/`:

```bash
mkdir -p ~/.claude/skills && ln -s ~/work/plan-critique-skills/skills/* ~/.claude/skills/
```

To update later, pull the clone and restart your Claude Code session:

```bash
git -C ~/work/plan-critique-skills pull
```

### Option 2: Per-project symlink install

Link each skill directory into a single repository's `.claude/skills/`:

```bash
mkdir -p .claude/skills && ln -s ~/work/plan-critique-skills/skills/* .claude/skills/
```

Installed via global or per-project symlinks, skills are invoked as:
- `/plan-create`
- `/plan-critique`
- `/plan-cycle`
- `/plan-execute`
- `/plan-archive`

### Option 3: Marketplace install

Add the marketplace and install the plugin from within Claude Code:

```
/plugin marketplace add serbanghita/plan-critique-skills
/plugin install plan@serbanghita
```

To refresh an installed plugin after updates, run `/reload-plugins` in Claude Code.

Installed as a plugin (`"name": "plan"`), skills are namespaced under `plan`:
- `/plan:plan-create`
- `/plan:plan-critique`
- `/plan:plan-cycle`
- `/plan:plan-execute`
- `/plan:plan-archive`

---

## Configuration

Settings are stored in `.claude/plan-critique-config.json`, with read fallback to `.gemini/plan-critique-config.json`
and `.copilot/plan-critique-config.json`:

```json
{
  "plansFolder": ".planning",
  "cycleIterations": 3
}
```

- If `plansFolder` is not set, `/plan-create` prompts for the location (default: `.planning`) and saves it to
  `.claude/plan-critique-config.json`.
- `cycleIterations` is optional and only read by `/plan-cycle`. It caps the critique and merge iterations of one
  run. Default `3`, valid range 1 to 5.
- Project instructions are resolved from `CLAUDE.md` first, falling back to `AGENTS.md`.
- Standing rules are read from `skills/plan-create/working-agreement.md` (included automatically via the `plan-create`
  skill folder).

---

## Usage Workflow

1. Create a plan:
   ```
   /plan-create "Add User Authentication"
   ```
   This creates `.planning/add-user-authentication/plan.md`.

2. Edit the plan:
   Fill in requirements, affected files, implementation steps, and verification approach.

3. Critique the plan:
   ```
   /plan-critique
   ```
   Claude performs an adversarial review and writes `.planning/add-user-authentication/critique.md`.

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
   Moves completed plan to `.planning/archived/add-user-authentication/`.

*(If installed via the Marketplace plugin, prefix commands with `plan:`, for example `/plan:plan-create`.)*

---

## One-pass cycle

`/plan-cycle` runs steps 1 to 4 of the workflow above in a single pass and stops before execution:

```
/plan-cycle "Add User Authentication"
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

Each terminal session tracks its own active plan using the Claude Code process ID (`$PPID`):
- Session state is saved in `.planning/.sessions/[PID]`.
- When running `/plan-critique` or `/plan-execute`, your session plan is auto-selected.
- Stale numeric-PID session files from closed processes are cleaned up automatically via `kill -0 [PID]` checks.
- Add `.planning/.sessions/` to `.gitignore`.
