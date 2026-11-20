# Project Standards

This project provides five planning skills for Codex, Claude Code, Antigravity / Gemini CLI, and GitHub Copilot CLI
from a single canonical `skills/` tree:

- All four agents read from `skills/` as
  `plan-create`, `plan-critique`, `plan-cycle`, `plan-execute`, and `plan-archive`.
- Codex skills are invoked as `$plan-create`, `$plan-critique`, `$plan-cycle`, `$plan-execute`, and `$plan-archive`.
- Other clients install manually or via symlink/config (`~/.claude/skills/`, `~/.agents/skills/`,
  `~/.gemini/config/skills.json`, or `/skills add`) and invoke the skills with `/plan-create`, `/plan-critique`,
  `/plan-cycle`, `/plan-execute`, and `/plan-archive`.
- Installed as a Claude Code plugin (`"name": "plan"`), skills are namespaced as `/plan:plan-create`,
  `/plan:plan-critique`, `/plan:plan-cycle`, `/plan:plan-execute`, and `/plan:plan-archive`.
- Installed as a Copilot CLI plugin, skills are invoked as `/plan-create`, `/plan-critique`, `/plan-cycle`,
  `/plan-execute`, and `/plan-archive`.

These skills help create, review, execute, and archive plans written by the user.

The `plan-cycle` skill is a shortcut through `plan-create` and `plan-critique`: it drafts `plan.md` only when the
user has not written one, then critiques and merges up to `cycleIterations` times (default 3) and stops for
approval. It merges on its own only the changes that are obvious, and asks the user about anything ambiguous,
anything that touches what the user wrote, and anything that changes the scope of a chapter. It never executes the
plan.

## Architecture

Session tracking for parallel plans:
- Each session tracks its current plan via a file in `.planning/.sessions/`.
- When `COPILOT_AGENT_SESSION_ID` is set (or on Copilot CLI, falling back to `default`), the session file is keyed
  by `COPILOT_AGENT_SESSION_ID` and stale non-PID session files not modified in the last 7 days are cleaned up.
- Otherwise (Codex, Claude Code and Antigravity), the session file is keyed by the process ID obtained via `echo $PPID`,
  and stale numeric-PID files are cleaned up opportunistically via `kill -0 [PID]` checks (never killing non-PID
  files).
- Skills read the session file to determine the current plan and show it as "(current session)" in selection.
- The `.sessions/` directory is local state and should be gitignored.

Per agent settings, manifests, and documentation:
- Codex discovers project skills from `.agents/skills/` and user skills from `~/.agents/skills/`.
- Config resolution checks the active agent's config file first (`.codex/plan-critique-config.json`,
  `.claude/plan-critique-config.json`,
  `.gemini/plan-critique-config.json`, or `.copilot/plan-critique-config.json`) and falls back to reading the other agent configs; new configs write to the active agent's file.
- Project instructions resolution checks the active agent's native file first (`AGENTS.md` for Codex, `GEMINI.md`,
  `.github/copilot-instructions.md`, or `CLAUDE.md`) and falls back to `AGENTS.md` then `CLAUDE.md`.
- Agent guides and manifests:
  - Codex: `docs/codex.md`.
  - Claude Code: `docs/claude-code.md`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`.
  - Agy / Antigravity: `docs/agy.md`.
  - Copilot CLI: `docs/copilot.md`, `.github/plugin/plugin.json`, `.github/plugin/marketplace.json`.

## Code Style

- The skill markdown files in `skills/` (each `SKILL.md` and its supporting `.md` files) should have a word wrap of
  maximum 120 characters.
- The markdown text should be minimal, do not use bold or italic text unless absolutely necessary.
- The markdown text should be mostly plain text paragraphs, ordered lists, emphasis on code with backticks and some
  code blocks.
- The markdown text should include thematic breaks (`---`) to separate sections.
- The text from the skill markdown files should be written in plain English and easy to read from a text editor
  even if markdown support is not available.
- Never use emojis in the markdown text.

## Versioning and Releases

- The canonical version lives in `.claude-plugin/plugin.json` under the `version` field.
- Follow semver: MAJOR for breaking changes, MINOR for new features, PATCH for fixes.
- Every release must update five things:
  1. `version` field in `.claude-plugin/plugin.json`
  2. `version` fields in `.github/plugin/plugin.json` and `.github/plugin/marketplace.json`
  3. The hardcoded version in the banners inside `skills/plan-create/SKILL.md` and `skills/plan-cycle/SKILL.md`
  4. `CHANGELOG.md` with a new section describing the changes
  5. A git tag in the format `v[VERSION]` (e.g. `v1.0.0`)

## Documentation

- Short and succinct.
- The README should stay minimal and cover:
  - Install: clone once (`~/work/plan-critique-skills`), global load from `skills/`, and update via `git pull` +
    `/skills reload` (or Claude Code restart / `/reload-plugins`), linking per-project and Marketplace options to `docs/`
  - Agent Compatibility Matrix
  - How it works / Usage (Pre-requisites, Skills overview, Working agreement, Parallel plans)
  - Credits
