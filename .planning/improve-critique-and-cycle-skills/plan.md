# Improve critique and cycle skills

Improve the Claude Code side of this repo (`skills/critique/`, `skills/cycle/`), focused on making iterative
planning (repeated critique-and-merge passes over `plan.md`) more correct and more useful. Antigravity
(`.gemini/skills/`) and Copilot CLI (`.github/skills/`) mirrors are out of scope for this plan; changes here are
Claude Code only unless a chapter says otherwise.

## Chapter 1: Anchor findings by chapter heading instead of raw line numbers

`skills/critique/SKILL.md` fixed rule 4 says line references are only valid for the copy of `plan.md` read in
that run, and its Notes (line 128-129) still tell the critique to write findings using `plan.md` line numbers.
`skills/cycle/SKILL.md` fixed rule 7 then has to work around this at merge time: "Do not carry a line range or
an index from the critique into the plan when the chapter will change the lines it points at: anchor to a
heading, a fence or a symbol instead." The anchor gets derived twice, once implicitly when the critique cites a
line, and once explicitly when cycle re-derives a heading/fence/symbol anchor before merging. Have the critique
write the heading/fence/symbol anchor directly into `critique.md` findings (line number as a secondary, best
effort hint only), so `cycle` and a human reader both get a stable reference without re-deriving it.

Affected files:

- skills/critique/SKILL.md (Notes section, around line 128-129: replace "make use of the line numbers" guidance
  with anchor-first guidance)
- skills/critique/critique-format.md (the finding block: add an `Anchor:` line alongside `Confidence:` and
  `Evidence:`)
- skills/cycle/SKILL.md (fixed rule 7: simplify, since the anchor now arrives pre-derived from critique.md
  instead of being re-derived at merge time)

Verification:

- Manually run `/plan:critique` against a multi-chapter fixture plan, edit a chapter above a flagged finding to
  shift its line numbers, run `/plan:critique` again, and confirm the finding's anchor (heading/fence/symbol)
  still resolves to the same text while the line number hint may have moved.

## Chapter 2: Add a plugin eval suite for critique and cycle

There is no automated test coverage for `skills/critique/SKILL.md` or `skills/cycle/SKILL.md` today; only
`scripts/validate-copilot-skills.sh` validates the Copilot mirror's markdown wrapping, not behavior. Add eval
cases (via `claude plugin eval`) that exercise the iterative-planning behaviors these two skills promise:
missing `Affected files` or `Verification` section is flagged, `critique.md` iteration number increments
correctly, cycle asks the user (does not silently merge) when a finding touches a requirement the user wrote, a
split recommendation is recorded as an open item rather than acted on during cycle, a finding's `Anchor:` field
resolves to real text (Chapter 1), `parallelCritique: true` produces one subagent-scoped critique per chapter
plus one aggregation pass while `false`/absent stays serial (Chapter 3), an oscillating finding is asked about
rather than auto-merged (Chapter 4), and cycle now requires two consecutive clean iterations after its last
merge before stopping, while a plan clean from iteration 1 still stops after one (Chapter 4).

`claude plugin eval` is an early access feature (no public docs page as of this writing); confirmed locally via
`claude plugin eval --help` that cases live under `evals/` by default (`<case>/prompt.md` plus
`<case>/graders/*.md`, or a `case.yaml`), so the plugin's `experimental.evals` manifest key is not needed unless
a non-default directory is wanted.

Affected files:

- evals/critique-flags-missing-sections/prompt.md and evals/critique-flags-missing-sections/graders/*.md (new)
- evals/critique-iteration-increments/prompt.md and graders/*.md (new)
- evals/critique-anchor-resolves/prompt.md and graders/*.md (new; Chapter 1's `Anchor:` field points at real
  text even after the plan changes above the finding)
- evals/critique-parallel-mode-branches/prompt.md and graders/*.md (new; Chapter 3's `parallelCritique: true`
  produces one subagent-scoped critique per chapter plus one aggregation pass, `false`/absent stays serial)
- evals/cycle-merge-gated-stop-condition/prompt.md and graders/*.md (new, replaces
  cycle-stops-on-no-new-findings; Chapter 4's revised stop condition: a plan clean from iteration 1 stops after
  one iteration, a plan that merges at least one finding needs two consecutive clean iterations afterward)
- evals/cycle-asks-before-touching-user-text/prompt.md and graders/*.md (new)
- evals/cycle-does-not-split-during-run/prompt.md and graders/*.md (new)
- evals/cycle-oscillation-not-auto-merged/prompt.md and graders/*.md (new; Chapter 4's oscillation check asks
  the user instead of auto-merging a finding that reverses an earlier merge)
- .claude-plugin/plugin.json (only if a non-default eval directory or manifest entry turns out to be needed;
  otherwise unchanged)

Verification:

- Run `claude plugin eval --case critique-flags-missing-sections` (and the same for each other case name above)
  and show passing graders in the output for each.

## Chapter 3: Parallelize per-chapter critique for large plans (Claude Code only)

`skills/critique/SKILL.md` step 13 critiques the whole plan in one serial pass. For a plan with many
independent chapters, most of the checks (clarity, completeness, feasibility, affected-files/verification
presence) are chapter-local and do not need the other chapters' context. Add an opt-in mode, gated by a new
`parallelCritique` boolean in `.claude/plan-critique-config.json` (default `false`, so behavior is unchanged
unless a user opts in), where the critique step spawns one subagent per chapter for the chapter-local checks,
then does a single serial pass afterward for the cross-chapter checks that need the whole plan (scope/split
evaluation, duplicate findings across chapters). This is Claude Code specific because the Agent/Task tool this
relies on has no equivalent invoked from `skills/cycle/SKILL.md` or `skills/critique/SKILL.md` on the Antigravity
or Copilot CLI side; do not port this to `.gemini/skills/` or `.github/skills/`.

Any subagent that is not the `fork` type starts with no memory of the parent run, so each per-chapter subagent
prompt must explicitly carry: the chapter's own text, the project's `CLAUDE.md` contents (or a summary), and the
LSP-availability flag already determined once upstream, so no subagent re-probes LSP or works without project
standards.

`skills/critique/SKILL.md` runs at `model: opus`, `effort: high`. Combined with `cycle`'s up to `cycleIterations`
(max 5) repeats, `parallelCritique` on an N-chapter plan can fire up to N x 5 opus/high-effort subagent calls in
one cycle run. Document this multiplier in docs/claude-code.md next to `parallelCritique`, since it applies
whether critique is invoked directly or from inside a cycle iteration.

Affected files:

- skills/critique/SKILL.md (step 13: branch on `parallelCritique`; add the per-chapter subagent step, its
  required briefing content, and the cross-chapter aggregation step)
- skills/cycle/SKILL.md (step 14: pass the same flag through when it delegates to critique's analysis steps)
- docs/claude-code.md (Configuration section: document `parallelCritique` and its cost multiplier with cycle)

Versioning for this chapter's change is not tracked here; see Chapter 5, which owns the full release checklist
for everything this plan ships.

Verification:

- Create a fixture plan with 5+ independent chapters, run `/plan:critique` with `parallelCritique: true` and
  confirm the transcript shows one subagent per chapter plus one aggregation pass; run again with the flag
  `false` or absent and confirm behavior matches the current serial critique (no regression).

## Chapter 4: Detect oscillating merges and match the two-consecutive-clean-passes bar

`working-agreement.md` (Tests, rule 3) requires bug hunting to continue "until two consecutive passes find
nothing new," but `skills/cycle/SKILL.md` fixed rule 9 stops the whole cycle after a single iteration with no
new findings. Separately, nothing in `skills/cycle/SKILL.md` step 14 checks whether a merge in iteration N
reverses a merge from iteration N-1 (the critique's own re-scan finding fault with a fix it endorsed one
iteration earlier). Tighten the stop condition to require two consecutive "no new findings" iterations (subject
to the existing `cycleIterations` cap, which already stops the loop early regardless), and add an oscillation
check before merging: if a CONFIRMED finding would undo a change recorded as merged anywhere in `cycle-log.md`
for the current run, not only in the immediately preceding iteration, do not auto-merge it, surface it to the
user instead per fixed rule 3.

The two-consecutive-clean requirement only starts counting after the first iteration that actually merges a
finding in the current run. A plan that is already clean on iteration 1 still stops after that one iteration,
same as today; the stricter bar only applies once the run has merged at least one change, so it cannot regress
the common case of a plan that was already correct.

Affected files:

- skills/cycle/SKILL.md (fixed rule 9, step 14: stop condition and the new oscillation check before the merge
  step)
- skills/cycle/cycle-log-format.md (add "reverses an earlier merge, asked" as an enumerated reason value under
  the existing `Asked` and `Not merged` sections, rather than a new top-level section)

Verification:

- Construct a plan.md fixture where an iteration-3 critique finding would exactly reverse an iteration-1 merge
  (with iteration 2 clean or unrelated), and confirm `/plan:cycle` still catches it and asks the user instead of
  applying the reversal, not only when the reversal targets the immediately preceding iteration. Separately
  confirm a plan that is clean on iteration 1 still stops after that one iteration (no regression), and that a
  plan needing at least one merge now takes two consecutive clean iterations after its last merge before cycle
  stops early.

## Chapter 5: Release checklist for this plan

Own the full six-item release checklist from CLAUDE.md (Versioning and Releases) once, for whatever version
this plan's combined changes ship as, instead of splitting it across chapters. Run this chapter last, after
Chapters 1 through 4 have landed.

Affected files:

- `.claude-plugin/plugin.json` (bump `version`)
- `.github/plugin/plugin.json` and `.github/plugin/marketplace.json` (bump `version` to match)
- `skills/create/SKILL.md` and `skills/cycle/SKILL.md` (bump the hardcoded `Plan Critique v...` banner)
- `.gemini/skills/plan-create/SKILL.md`, `.gemini/skills/plan-cycle/SKILL.md`, `.github/skills/plan-create/SKILL.md`
  and `.github/skills/plan-cycle/SKILL.md` (same banner bump)
- `CHANGELOG.md` (new section describing Chapters 1 through 4)

Verification:

- Grep the repo for the old version string and confirm zero remaining matches outside `CHANGELOG.md`'s history;
  confirm all three `plugin.json`/`marketplace.json` files and all six banner locations show the same new
  version; create the git tag `v[VERSION]` last, after the version-bump commit.
