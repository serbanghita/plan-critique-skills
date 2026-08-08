# Update Repository Documentation and Configuration for Multi-Agent Support

> Keywords: documentation, multi-agent, claude-code, agy, copilot, rename, remotes, install

## Goals

Update the repository documentation, configuration, manifests, and skills to reflect the project rename to `plan-critique-skills` (https://github.com/serbanghita/plan-critique-skills) and establish first-class multi-agent support for Claude Code, Agy (Gemini CLI), and GitHub Copilot CLI.

---

## Chapter 1 - Local Git Remote Update

Affected files: None (Git configuration)
Verification: Run `git remote -v` and verify origin URL points to `plan-critique-skills`.

Steps:
1. Update git remote origin to the new repository URL:
   ```bash
   git remote set-url origin git@github.com:serbanghita/plan-critique-skills.git
   ```
2. Verify remote URLs:
   ```bash
   git remote -v
   ```

---

## Chapter 2 - Plugin and Marketplace Manifests

Affected files:
- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `.github/plugin/plugin.json`
- `.github/plugin/marketplace.json`

Verification: Validate JSON syntax and inspect repository / homepage fields.

Steps:
1. Update `repository` field in `.claude-plugin/plugin.json` to `https://github.com/serbanghita/plan-critique-skills`.
2. Update `homepage` and `repository` fields in `.github/plugin/plugin.json` to `https://github.com/serbanghita/plan-critique-skills`.
3. Verify plugin descriptions in `.claude-plugin/marketplace.json` and `.github/plugin/marketplace.json`.

---

## Chapter 3 - README and Dedicated Agent Sub-Guides

Affected files:
- `README.md`
- `docs/claude-code.md`
- `docs/agy.md`
- `docs/copilot.md`

Verification: Render and review markdown structure, links, installation commands, and formatting across all documentation files.

Steps:
1. Create `docs/claude-code.md` covering Claude Code marketplace and manual installation, `/plan:*` commands, `.claude/plan-critique-config.json`, `CLAUDE.md`, and `$PPID` session management.
2. Create `docs/agy.md` covering Agy / Gemini CLI / Antigravity workspace (`.gemini/skills/`) and global (`~/.gemini/config/skills/`) installation, `/plan-*` commands, config fallback, and `GEMINI.md`/`AGENTS.md` standards.
3. Create `docs/copilot.md` covering GitHub Copilot CLI marketplace and manual installation, `/plan-*` commands, `.copilot/` config, and `COPILOT_AGENT_SESSION_ID` session tracking.
4. Overhaul `README.md`:
   - Set title to `# plan-critique-skills` and update tagline.
   - Add an **Agent Guides** section with links to `docs/claude-code.md`, `docs/agy.md`, and `docs/copilot.md`.
   - Reorganize `## Install` into dedicated subsections for Claude Code, Agy (Gemini CLI), and GitHub Copilot CLI with both marketplace and manual install commands.
   - Add an **Agent Compatibility Matrix** comparing skill names, storage paths, config files, session keys, and project standards files.
   - Update workflow diagram, pre-requisites, working agreement summary, and parallel session descriptions.
   - Update all repository clone URLs to `https://github.com/serbanghita/plan-critique-skills.git`.

---

## Chapter 4 - Project Guidelines and Working Agreement

Affected files:
- `CLAUDE.md`
- `working-agreement.md`

Verification: Verify rule references and release checklist.

Steps:
1. Update `working-agreement.md` line 48 to include `GEMINI.md` in the durable project instruction files list (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.github/copilot-instructions.md`).
2. Update `CLAUDE.md` to document the `docs/` sub-guides, multi-agent layout architecture, config fallback paths, and release checklist.

---

## Chapter 5 - Skills Configuration and Standards Consistency

Affected files:
- `.gemini/skills/plan-create/SKILL.md`
- `.gemini/skills/plan-critique/SKILL.md`
- `.gemini/skills/plan-execute/SKILL.md`
- `.gemini/skills/plan-archive/SKILL.md`

Verification: Grep for hardcoded `.claude/` paths and `CLAUDE.md` references in `.gemini/skills/` to verify fallback support and instruction file flexibility.

Steps:
1. Update `.gemini/skills/` to check `.gemini/plan-critique-config.json` with fallback to `.claude/plan-critique-config.json`.
2. Update standards detection in `.gemini/skills/` to accept `GEMINI.md`, `AGENTS.md`, or `CLAUDE.md`.
3. Update session PID description in `.gemini/skills/` to refer to Agy / Gemini CLI session.

---

## Chapter 6 - Changelog Entry

Affected files:
- `CHANGELOG.md`

Verification: Check changelog formatting, version headings, and clarity.

Steps:
1. Add an entry at the top of `CHANGELOG.md` documenting:
   - Project rename to `plan-critique-skills` (https://github.com/serbanghita/plan-critique-skills).
   - First-class multi-agent support across Claude Code, Agy (Gemini CLI), and GitHub Copilot CLI.
   - New dedicated agent sub-guides in `docs/` (`docs/claude-code.md`, `docs/agy.md`, `docs/copilot.md`).
   - Unified installation and compatibility documentation in `README.md`.
