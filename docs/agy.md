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
- `/plan-execute` - Step-by-step verified execution with progress tracking
- `/plan-archive` - Move completed plan to `.planning/archived/`

---

## Configuration

Settings are stored in `.gemini/plan-critique-config.json` with fallback to `.claude/plan-critique-config.json`:

```json
{
  "plansFolder": ".planning"
}
```

- If `plansFolder` is not set, `/plan-create` prompts for the location (default: `.planning`).
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

## Parallel Plans and Session Tracking

Each terminal session tracks its own active plan using the process ID (`$PPID`):
- Session state is saved in `.planning/.sessions/[PID]`.
- When running `/plan-critique` or `/plan-execute`, your session plan is auto-selected.
- Stale session files from closed processes are cleaned up automatically via `kill -0 [PID]` checks.
- Add `.planning/.sessions/` to `.gitignore`.
