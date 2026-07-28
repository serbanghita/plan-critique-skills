# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-07-28

### Added
- A `working-agreement.md` at the repository root holding standing rules for planning, verification, tests,
  context, output style and git. It is the single canonical copy of the rule text.
- `create`, `critique` and `execute` each open with a `Fixed rules` block that reads the working agreement and
  lists the rules binding that phase. The rules override any conflicting step in the skill body.
- `create` writes a plan template with required `Affected files` and `Verification` sections in every chapter.
- `critique` records `Confidence` (CONFIRMED or UNVERIFIED) and `Evidence` on every issue in `critique.md`, and
  raises a finding when a plan chapter omits its affected files or its verification approach.
- `execute` detects test infrastructure before running any step. Where a suite exists, tests-first is binding
  and a step is not marked COMPLETED until the suite passes. Where none exists, steps are reported as unverified
  rather than done. The execution log gains a `Tests` line per step and a `Verified by tests` summary count.

### Changed
- Manual install now also copies `working-agreement.md` into `.claude/` so the skills can resolve it.

## [2.1.0] - 2026-07-28

### Added
- Made the repository Antigravity (`agy`) compatible by mirroring skills to `.gemini/skills/` with the `plan:` prefix format. This enables usage of `/plan:create`, `/plan:critique`, `/plan:execute`, and `/plan:archive` in the Antigravity CLI.

## [2.0.1] - 2026-05-27

### Fixed
- Added a `description` to `marketplace.json`, clearing the `claude plugin validate` warning and
  helping users understand what the marketplace offers.

## [2.0.0] - 2026-05-27

### Changed
- BREAKING: migrated from slash commands to the Skills format. The four commands now live as skills
  under `skills/create`, `skills/critique`, `skills/execute`, and `skills/archive`.
- BREAKING: the plugin is renamed from `plan-critique` to `plan`. Install with
  `/plugin install plan@serbanghita`. Marketplace users invoke the namespaced `/plan:create`,
  `/plan:critique`, `/plan:execute`, `/plan:archive`; manual installs use the bare `/create`,
  `/critique`, `/execute`, `/archive`.
- BREAKING: manual install now copies `skills/*` into `.claude/skills/` (previously `.claude/commands/`).
  Delete any old `.claude/commands/plan-*.md` files from prior manual installs.
- Large format blocks were extracted into per-skill supporting files (`plan-template.md`,
  `critique-format.md`, `execution-log-format.md`, `execution-state-format.md`, `archive-info-format.md`)
  and linked from each `SKILL.md`, loaded on demand for leaner skill bodies.
- Removed the now-unused `commands` array from `plugin.json`; skills are auto-discovered from `skills/`.

## [1.4.0] - 2026-05-26

### Added
- `/plan-create` accepts the plan name as an inline argument, e.g. `/plan-create Add User Authentication`.
  When a name is passed it is used directly; otherwise the command prompts for one as before. Added an
  `argument-hint` so the expected `[plan name]` shows in autocomplete.

## [1.3.0] - 2026-05-26

### Added
- Marketplace installation: added `.claude-plugin/marketplace.json` and a "Marketplace installation
  (recommended)" section in the README, enabling install via `/plugin install plan-critique@serbanghita`.
- `/plan-critique` now pins `model: opus` and `effort: high` via frontmatter, so reviews always run on the
  top model with deep reasoning. This replaces prose directives ("Think hard", "Always use the top model")
  that had no effect on model or reasoning selection.
- `LSP` added to `/plan-critique` allowed-tools so the go-to-definition and find-references steps the command
  already describes can run without a permission prompt.

### Changed
- `/plan-execute` and `/plan-archive` now set `disable-model-invocation: true`. These stateful commands run
  only when the user invokes them and are never auto-triggered by the model.
- `/plan-execute` allowed-tools cleaned up: removed redundant scoped `Bash(...)` entries already covered by
  the broad `Bash` permission that plan execution requires.
- Raised `minClaudeCodeVersion` to `2.1.0`, the baseline for the command/skill frontmatter features the plugin
  now relies on (`model`/`effort`, `disable-model-invocation`).

## [1.2.0] - 2026-03-26

### Added
- Critique context: `/plan-execute` now reads `critique.md` as supplementary context during execution,
  carrying forward implementation hints, risk warnings, and alternative approaches from the critique phase.
- Plan readiness check: warns if a plan has not been critiqued before execution, with option to proceed.
- Git integration: per-step commits with rollback capability. After each step, offers to commit changes
  with a `plan-execute:` prefixed message. Tracks commit hashes in execution state for `git revert`.
- Post-step verification: runs `mcp__ide__getDiagnostics` on modified files after each step to catch
  new errors early. Advisory only, does not block execution.
- Error recovery options: on failure, presents four choices instead of just stopping: fix and retry,
  skip step, rollback via git revert, or stop execution.
- CLAUDE.md context: reads project standards at the start of execution and enforces compliance.
- Dependency graph: step presentation now shows inferred dependencies between steps and estimated
  file impact per step, with option for the user to reorder before execution begins.
- Supporting file classification: supporting files are classified by type and purpose, presented to
  the user for confirmation before execution.
- Step-level timing and file tracking in execution log.
- Context window warning for plans exceeding 10 steps.

### Changed
- Resume flow: on resume, verifies git state matches execution state. On restart, explicitly
  overwrites execution-log.md and notes the restart.
- Execution state format: added `skippedSteps`, `stepStartedAt`, `gitAvailable`, and `gitCommits`
  fields to `execution-state.json`.
- Execution log format: added `Duration` and `Files changed` fields per step, `Git commits` in
  summary. Failed steps now include verbatim error output.

## [1.1.0] - 2026-02-16

### Changed
- Session plan auto-selection: `/plan-critique`, `/plan-execute`, and `/plan-archive` now auto-select the current
  session plan instead of prompting every time. Plan selection prompt only appears when no session plan exists and
  multiple plans are available.

## [1.0.1] - 2026-02-09

### Changed
- Moved canonical version from VERSION file to `.claude-plugin/plugin.json`
- Hardcoded version in `/plan-create` banner to avoid reading files at runtime
- Removed unused `currentPlan` field from config file

### Removed
- VERSION file (replaced by plugin.json version field)

## [1.0.0] - 2026-02-08

### Added
- VERSION file for tracking releases
- Banner displayed at the start of `/plan-create` showing the current version
- CHANGELOG.md for documenting changes
- Versioning and release process documented in CLAUDE.md

### Changed
- Simplified the proposed ASCII banner to a plain-text box that fits 80-column terminals

## Pre-release history

Changes prior to the 1.0.0 release, grouped from the commit log.

### 2026-02-04

- Architectural changes mentioned in CLAUDE.md after plan execution (9dc4a7e)
- Improved README structure (a651ae3)

### 2026-01-14

- Critique command updated to the format of Claude Code official commands (a072042)
- All commands updated to follow the latest project standards (dda5f36)
- Fixed the install command (2314f68)
- Clarified plan naming rules (b4b66a2)
- Added line number references to the critique step (21880a9)

### 2026-01-13

- Added more clarity to critique and plan creation (5e6004d)
- Plan creation now forces the user to provide a custom plan name (72945be)
- Added "How it works" documentation (d99a75a)
- Improvements in clarity across commands (399e78b)
- Plan and Critique formatting refinements (5e6e102)

### 2026-01-12

- Initial release of claude-code-plan-critique (e42caad)
- Plugin packaging and publish setup (66eccdd)
- Installation process via git clone (0cda021, da14e61, bd0257d, a0e4e06)
