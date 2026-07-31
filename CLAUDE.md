# Project Standards

This project provides four planning skills for three agents.

- Claude Code reads them from `skills/` as `create`, `critique`, `execute` and `archive`. Installed as a plugin
  they are invoked as `/plan:create`, `/plan:critique`, `/plan:execute` and `/plan:archive`; installed manually
  they are invoked bare as `/create`, `/critique`, etc.
- Antigravity reads them from `.gemini/skills/` as `plan-create`, `plan-critique`, `plan-execute` and
  `plan-archive`.
- GitHub Copilot CLI reads them from `.github/skills/` as `plan-create`, `plan-critique`, `plan-execute` and
  `plan-archive`, invoked as `/plan-create`, `/plan-critique`, `/plan-execute` and `/plan-archive`.

These skills help create, review, execute, and archive plans written by the user.

## Architecture

Session tracking for parallel plans:
- Each session tracks its current plan via a file in `.planning/.sessions/`.
- Claude Code and Antigravity key the file by the process ID obtained via `echo $PPID`, and clean up stale files
  opportunistically via `kill -0 [PID]` checks.
- Copilot CLI keys the file by the `COPILOT_AGENT_SESSION_ID` environment variable, and cleans up session files
  that have not been modified in the last 7 days. It never shells out to `$PPID` or `kill`, because those do not
  work on Windows.
- Skills read the session file to determine the current plan and show it as "(current session)" in selection.
- The `.sessions/` directory is local state and should be gitignored.

Per agent settings and manifests:
- Claude Code: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, config in
  `.claude/plan-critique-config.json`, project standards in `CLAUDE.md`.
- Copilot CLI: `.github/plugin/plugin.json`, `.github/plugin/marketplace.json`, config in
  `.copilot/plan-critique-config.json` with a fallback read of `.claude/plan-critique-config.json`, project
  standards in `.github/copilot-instructions.md`, `AGENTS.md` or `CLAUDE.md`.
- The Copilot skills carry `name`, `description` and `license` frontmatter. They do not carry `allowed-tools`,
  `argument-hint`, `model` or `effort`, which are Claude Code fields.

## Code Style

- The skill markdown files in the `skills/`, `.gemini/skills/` and `.github/skills/` folders (each `SKILL.md` and
  its supporting `.md` files) should have a word wrap of maximum 120 characters.
- The markdown text should be minimal, do not use bold or italic text unless absolutely necessary.
- The markdown text should be mostly plain text paragraphs, ordered lists, emphasys on code with backticks and some code blocks.
- The markdown text should include thematic breaks (`---`) to separate sections.
- The text from the skill markdown files should be written in plain English and easy to read from a text editor
  even if markdown support is not available.
- Never use emojis in the markdown text.

## Versioning and Releases

- The canonical version lives in `.claude-plugin/plugin.json` under the `version` field.
- Follow semver: MAJOR for breaking changes, MINOR for new features, PATCH for fixes.
- Every release must update six things:
  1. `version` field in `.claude-plugin/plugin.json`
  2. `version` fields in `.github/plugin/plugin.json` and `.github/plugin/marketplace.json`
  3. The hardcoded version in the banner inside `skills/create/SKILL.md`
  4. The same banner inside `.gemini/skills/plan-create/SKILL.md` and `.github/skills/plan-create/SKILL.md`
  5. `CHANGELOG.md` with a new section describing the changes
  6. A git tag in the format `v[VERSION]` (e.g. `v1.0.0`)

## Documentation

- Short and succinct
- The README should have three major sections:
  - Install
    - Marketplace installation (recommended), per agent
    - Manual installation via git clone, per agent
  - Usage
    - Pre-requisites
    - Skills overview
    - Workflow steps
  - Credits
