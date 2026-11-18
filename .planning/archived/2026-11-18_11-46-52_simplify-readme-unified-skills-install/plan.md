# Simplify README and Unified Skills Install

Goal: Consolidate all three agents onto `/path/to/plan-critique-skills/skills` via a single clone-once workflow so updates require only `git pull` and `/skills reload` (or session restart in Claude Code), with zero copy-paste and a minimal `README.md`.
Non-goals: Changing the core `create -> critique -> cycle -> execute -> archive` workflow logic or removing Marketplace/Plugin support completely (moved to `docs/`).

## 1. Unify agent-agnostic runtime behavior in `skills/`

Merge the agent-specific differences from `.gemini/skills/` and `.github/skills/` into `skills/` so one skill tree serves Claude Code, Agy (Gemini CLI / Antigravity), and GitHub Copilot CLI.

- Prompt input: Accept either `$ARGUMENTS` (Claude Code) or a plan name passed in the invoking prompt (Copilot/Agy).
- Config resolution: Check the active agent's config file first (`.claude/plan-critique-config.json`, `.gemini/plan-critique-config.json`, or `.copilot/plan-critique-config.json`), falling back to reading the other two; when none exists or `plansFolder` is unset, prompt the user and save to the active agent's config file.
- Project standards lookup: Check the active agent's native instructions file first (`GEMINI.md` for Agy, `.github/copilot-instructions.md` for Copilot, `CLAUDE.md` for Claude), falling back to `AGENTS.md` then `CLAUDE.md`.
- Cross-platform session tracking: Use `COPILOT_AGENT_SESSION_ID` (`echo $COPILOT_AGENT_SESSION_ID` or PowerShell `$env:COPILOT_AGENT_SESSION_ID`, falling back to literal `default` on Copilot/Windows if empty) with 7-day mtime cleanup; otherwise use `$PPID` and numeric-PID-only `kill -0` cleanup (preserving non-PID Copilot session files). Update `allowed-tools` in `plan-create`, `plan-critique`, and `plan-archive` to cover `COPILOT_AGENT_SESSION_ID` and mtime cleanup.
- Frontmatter and skill naming: Rename directories to `skills/plan-{create,critique,cycle,execute,archive}` with `name: plan-*` in frontmatter so `/plan-create`..`/plan-archive` work consistently across Agy, Copilot, and manual/symlinked Claude installs. Keep `"name": "plan"` in `.claude-plugin/plugin.json` for `plan@serbanghita` marketplace compatibility (Claude Code plugins register `/plan:plan-create`..`/plan:plan-archive`), and keep `allowed-tools`, `argument-hint`, `model` (add `model: opus` to `plan-critique`), and `effort` alongside `name`, `description`, and `license` (to be verified by `validate-copilot-skills.sh` in Chapter 2).
- Code intelligence fallback: Use `mcp__ide__getDiagnostics` when available and otherwise fall back to LSP hover/definition / code intelligence; accept either the `LSP` tool or an active language server, show agent-appropriate setup hints (`/plugins` vs `/lsp`), and include `/model` guidance for agents that ignore model frontmatter.
- Working agreement and command parity: Read `[working-agreement.md](working-agreement.md)` directly in `plan-create` and `[working-agreement.md](../plan-create/working-agreement.md)` directly in `plan-critique`, `plan-cycle`, and `plan-execute` (removing all stale fallback search paths, since `plan-create` is always present; if missing, report it and apply the inline rules). Update all internal cross-skill relative links (`../plan-create/plan-template.md`, `../plan-create/SKILL.md`, `../plan-critique/SKILL.md`, `../plan-critique/critique-format.md`), restore project-root `` `CLAUDE.md` `` in `skills/plan-create/working-agreement.md` (currently `../../CLAUDE.md`), add multi-config and cross-platform session parity to `skills/plan-archive/SKILL.md` (without adding `working-agreement.md` to `plan-archive`), generalize hardcoded `CLAUDE.md` / `.claude/` / `Claude` body wording, and update `/plan:create`..`/plan:archive` hints, agent-neutral LSP/language-server wording (`critique-format.md:16`), and `plan-*` names across `SKILL.md` and all 6 format/template files (`plan-template.md`, `critique-format.md`, `cycle-log-format.md`, `execution-log-format.md`, `execution-state-format.md`, `archive-info-format.md`).

Affected files:

- skills/create/SKILL.md -> skills/plan-create/SKILL.md (modify)
- skills/create/plan-template.md -> skills/plan-create/plan-template.md (modify)
- skills/create/working-agreement.md -> skills/plan-create/working-agreement.md (modify)
- skills/critique/SKILL.md -> skills/plan-critique/SKILL.md (modify)
- skills/critique/critique-format.md -> skills/plan-critique/critique-format.md (modify)
- skills/cycle/SKILL.md -> skills/plan-cycle/SKILL.md (modify)
- skills/cycle/cycle-log-format.md -> skills/plan-cycle/cycle-log-format.md (modify)
- skills/execute/SKILL.md -> skills/plan-execute/SKILL.md (modify)
- skills/execute/execution-log-format.md -> skills/plan-execute/execution-log-format.md (modify)
- skills/execute/execution-state-format.md -> skills/plan-execute/execution-state-format.md (modify)
- skills/archive/SKILL.md -> skills/plan-archive/SKILL.md (modify)
- skills/archive/archive-info-format.md -> skills/plan-archive/archive-info-format.md (modify)

Verification:

- Confirm every `SKILL.md` in `skills/plan-*/` has `name: plan-*`, checks all 3 config files, and handles `COPILOT_AGENT_SESSION_ID` + `$PPID`, and confirm `plan-create`, `plan-critique`, `plan-cycle`, and `plan-execute` (excluding `plan-archive`) resolve `working-agreement.md` via `plan-create` (`grep -rl "^name: plan-" skills/plan-*/SKILL.md | wc -l` is 5; `grep -rl "COPILOT_AGENT_SESSION_ID" skills/plan-*/SKILL.md | wc -l` is 5).
- Confirm no old cross-skill relative links or `/plan:` hints remain in `skills/` (`grep -rnE '\.\./(create|critique|cycle|execute|archive)/|/plan:(create|critique|cycle|execute|archive)' skills/` returns empty).
- Confirm all lines in `skills/` markdown files stay <= 120 characters (`find skills -type f -name '*.md' -print0 | xargs -0 awk 'length > 120 { print FILENAME ":" FNR ":" length; fail=1 } END { exit fail }'`).

## 2. Remove duplicate skill trees and update manifests and CI

Delete `.gemini/skills/` and `.github/skills/` and point plugin manifests, `CLAUDE.md`, and CI validation directly at `skills/`.

- Manifests: Update `.github/plugin/plugin.json` and `.github/plugin/marketplace.json` `"skills"` field from `[".github/skills"]` to `["skills"]`.
- Validation script: Update `scripts/validate-copilot-skills.sh` to run `find "$repository_root/skills"` only (removing `.gemini/skills` and `.github/skills` so `find` does not error on deleted dirs), symlink `skills/` instead of `.github/skills`, remove the stale root `working-agreement.md` symlink/checks (lines 95, 98-99) in favor of `plan-create/working-agreement.md` inside `skills/`, and keep `expectedNames` as `plan-*`.
- Repo standards: Update `CLAUDE.md` `# Project Standards` (lines 5-13), `## Architecture` (lines 25-42, removing lines 41-42 and updating config/session notes), `## Code Style` (line 46), `## Versioning and Releases` (line 59 six -> five; lines 62-64 removing `.gemini/skills` / `.github/skills`), and `## Documentation` (lines 71-79, aligning `README.md` outline with Chapter 3).

Affected files:

- .gemini/skills/plan-archive/SKILL.md (delete)
- .gemini/skills/plan-archive/archive-info-format.md (delete)
- .gemini/skills/plan-create/SKILL.md (delete)
- .gemini/skills/plan-create/plan-template.md (delete)
- .gemini/skills/plan-critique/SKILL.md (delete)
- .gemini/skills/plan-critique/critique-format.md (delete)
- .gemini/skills/plan-cycle/SKILL.md (delete)
- .gemini/skills/plan-cycle/cycle-log-format.md (delete)
- .gemini/skills/plan-execute/SKILL.md (delete)
- .gemini/skills/plan-execute/execution-log-format.md (delete)
- .gemini/skills/plan-execute/execution-state-format.md (delete)
- .github/skills/plan-archive/SKILL.md (delete)
- .github/skills/plan-archive/archive-info-format.md (delete)
- .github/skills/plan-create/SKILL.md (delete)
- .github/skills/plan-create/plan-template.md (delete)
- .github/skills/plan-critique/SKILL.md (delete)
- .github/skills/plan-critique/critique-format.md (delete)
- .github/skills/plan-cycle/SKILL.md (delete)
- .github/skills/plan-cycle/cycle-log-format.md (delete)
- .github/skills/plan-execute/SKILL.md (delete)
- .github/skills/plan-execute/execution-log-format.md (delete)
- .github/skills/plan-execute/execution-state-format.md (delete)
- .github/plugin/plugin.json (modify)
- .github/plugin/marketplace.json (modify)
- scripts/validate-copilot-skills.sh (modify)
- CLAUDE.md (modify)

Verification:

- Run `bash scripts/validate-copilot-skills.sh` (if `copilot` CLI is installed; otherwise run its offline `awk 'length > 120'` and symlink/`test -f` checks) and confirm all assertions pass.
- Grep Chapter 1-2 repo files for stale `.gemini/skills`, `.github/skills`, and unprefixed `skills/(create|critique|cycle|execute|archive)` references (`grep -rnE "\.gemini/skills|\.github/skills|skills/(create|critique|cycle|execute|archive)" .claude-plugin .github scripts CLAUDE.md skills | grep -v 'manual_project/\.github/skills'` returns empty).

## 3. Simplify `README.md` around clone-once and global load

Replace copy-paste `cp` snippets and Marketplace install blocks in `README.md` with a single clone-once global setup pointing to `/path/to/plan-critique-skills/skills`.

- Clone step: Show one `git clone https://github.com/serbanghita/plan-critique-skills.git ~/work/plan-critique-skills` command shared by all three agents.
- Global load step (zero copy-paste): Point each agent to `~/work/plan-critique-skills/skills` globally using ONE method per agent so directories are not clobbered or double-loaded: for Claude Code, `mkdir -p ~/.claude/skills && ln -s ~/work/plan-critique-skills/skills/* ~/.claude/skills/`; for Agy/Gemini, EITHER `mkdir -p ~/.agents/skills && ln -s ~/work/plan-critique-skills/skills/* ~/.agents/skills/` OR register `~/work/plan-critique-skills/skills` in `~/.gemini/config/skills.json`; for Copilot CLI, EITHER symlink into `~/.agents/skills/` OR run `/skills add ~/work/plan-critique-skills/skills`.
- Update loop: Document `git -C ~/work/plan-critique-skills pull` followed by `/skills reload` in Gemini CLI and Copilot CLI, or a session restart in Claude Code (and `/reload-plugins` for Marketplace plugin installs).
- Trim README bloat: Move Marketplace/Plugin installs and per-project install variants to `docs/`, update `Agent Compatibility Matrix` (`Manual Skill Names` -> `/plan-create`..`/plan-archive`, `Plugin Skill Names` -> `/plan:plan-create`..`/plan:plan-archive` for Claude Code and `/plan-*` for Copilot, `Skill Storage` -> `skills/`, `Config File` -> active agent first with cross-fallback, `Project Standards` -> native first with `AGENTS.md`/`CLAUDE.md` fallback), and update `skills/create/working-agreement.md` references to `skills/plan-create/working-agreement.md`.

Affected files:

- README.md (modify)

Verification:

- Confirm zero `cp` / `rm -rf` install snippets or stale `.gemini/skills`, `plan-critique-skills/.github/skills`, or `skills/create` paths remain in `README.md` (`grep -nE '(^|[[:space:]`])(cp|rm[[:space:]]+-rf)([[:space:]]|$)|\.gemini/skills|plan-critique-skills/\.github/skills|skills/(create|critique|cycle|execute|archive)' README.md` returns empty).
- Confirm all relative file links in `README.md` resolve on disk (e.g., `docs/claude-code.md`, `docs/agy.md`, `docs/copilot.md`, `skills/plan-create/working-agreement.md` via `test -f`).

## 4. Align `docs/` agent guides with unified install and secondary options

Update the three agent guides so global clone-and-link from `skills/` is the primary path and per-project + Marketplace/Plugin options live cleanly in `docs/`.

- Primary flow: Replace `cp` instructions in `docs/claude-code.md` and `.gemini/skills` / `.github/skills` source paths in `docs/agy.md` and `docs/copilot.md` with the unified `~/work/plan-critique-skills/skills` path and `git pull` + `/skills reload` (including adding `/skills reload` to `docs/agy.md`, and session restart / `/reload-plugins` in `docs/claude-code.md`).
- Secondary options and stale-link cleanup: Keep per-project linking (`.claude/skills`, `.agents/skills.json`, `.github/skills`) and Marketplace/Plugin install sections in the respective agent guides, update `docs/claude-code.md` commands (`/plan-create`..`/plan-archive` for primary symlink install and `/plan:plan-create`..`/plan:plan-archive` for Marketplace plugin install), remove the broken `.github/working-agreement.md` symlink in `docs/copilot.md:22`, fix `../skills/create/working-agreement.md` across `docs/{claude-code,agy,copilot}.md`, and align `Configuration`, `Parallel Plans`, and `/plan-*` command examples.

Affected files:

- docs/claude-code.md (modify)
- docs/agy.md (modify)
- docs/copilot.md (modify)

Verification:

- Grep `docs/` for stale `.gemini/skills`, `plan-critique-skills/.github/skills`, `cp -r`, `skills/create`, and verify all `working-agreement.md` references point to `skills/plan-create/working-agreement.md` or `../plan-create/working-agreement.md` (`grep -rn "working-agreement\.md" docs/`).
