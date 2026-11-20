The `plan-cycle` skill appends one run block per invocation and one entry per iteration to
`[plansFolder]/[selected-plan]/cycle-log.md` using this format.

Merging is automatic for the obvious changes only, so this file is the audit trail. Every finding the cycle
applied to `plan.md`, every finding it asked the user about with the answer it got, every finding it skipped with
the reason, and every unchanged repeat finding under `Previously decided` are listed here. When an `Asked` entry
is `Applied:` and reverses an earlier merge, it supersedes that earlier entry for subsequent oscillation checks.
When an oscillating finding is declined or left unapplied, record it under `Asked` and also under `Not merged`
with `Reason: reverses an earlier merge, asked`. Findings are never dropped silently and changes are never guessed.

```markdown
# Plan Cycle Log: [Plan Title]

Plan drafted by: [cycle | user]

---

## Run [n]

Started: [YYYY-MM-DD HH:MM:SS]

---

## Iteration [number]

Findings: [X CONFIRMED, Y UNVERIFIED]
Merged: [count]
Asked: [count]
Not merged: [count]
Previously decided: [count]

Merged:

- [Plan chapter title] - [one line on what changed in plan.md]

Asked:

- [Plan chapter title] - [the question put to the user]
  Answer: [Applied: | Declined:] [what the user chose, and what was written to plan.md as a result]
  Reason: [optional: reverses an earlier merge, asked]

Not merged:

- [Plan chapter title] - [one line on the finding]
  Reason: [user declined the change | reverses an earlier merge, asked | evidence missing |
  UNVERIFIED and would lose information | split recommendation, left for the user]
  Evidence: [file:line or command output, or "missing"]

Previously decided:

- [Plan chapter title] - [one line on the finding]
  Evidence: [unchanged evidence]

---

[Repeat for each iteration]

## Summary

- Iterations run: [X of Y]
- Stopped because: [no new findings | two consecutive clean passes | iteration limit reached]
- Questions asked: [count, or "none"]
- Open items: [count of deduplicated findings not merged across unfinished/active runs, or "none"]
```
