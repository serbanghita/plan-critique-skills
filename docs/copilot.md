# Plan & Critique Skills for GitHub Copilot CLI

Iterative, adversarial plan review and execution skills for GitHub Copilot CLI.

---

## Install

### Option 1: Marketplace install (recommended)

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

Verify installed skills:

```bash
copilot skill list
```

Reload skills during a session:

```
/skills reload
```

### Option 2: Manual install

Clone the repository and copy the skills and working agreement:

```bash
git clone https://github.com/serbanghita/plan-critique-skills.git && \
mkdir -p .github/skills && \
cp -r plan-critique-skills/.github/skills/* .github/skills/ && \
cp plan-critique-skills/working-agreement.md . && \
rm -rf plan-critique-skills
```

---

## Available Skills

Copilot CLI skills carry the `plan-` prefix:
- `/plan-create` - Create a new plan folder with `plan.md` template
- `/plan-critique` - Adversarial review of `plan.md`, generating `critique.md`
- `/plan-execute` - Step-by-step verified execution with progress tracking
- `/plan-archive` - Move completed plan to `.planning/archived/`

---

## Configuration

Settings are stored in `.copilot/plan-critique-config.json` with fallback to `.claude/plan-critique-config.json`:

```json
{
  "plansFolder": ".planning"
}
```

- If `plansFolder` is not set, `/plan-create` prompts for the location (default: `.planning`).
- Project standards are read from `.github/copilot-instructions.md`, `AGENTS.md`, or `CLAUDE.md`.
- Standing rules are read from `working-agreement.md` located in the plugin or project root.

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

## Parallel Plans and Session Tracking

Each Copilot session tracks its active plan using the `COPILOT_AGENT_SESSION_ID` environment variable:
- Session state is saved in `.planning/.sessions/[SESSION_ID]`.
- When running `/plan-critique` or `/plan-execute`, your session plan is auto-selected.
- Session files older than 7 days are cleaned up automatically without process-killing shell dependencies (Windows compatible).
- Add `.planning/.sessions/` to `.gitignore`.
