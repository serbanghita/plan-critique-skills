The `cycle` skill appends one entry per iteration to `[plansFolder]/[selected-plan]/cycle-log.md` using this
format.

Merging is automatic for the obvious changes only, so this file is the audit trail. Every finding the cycle
applied to `plan.md`, every finding it asked the user about with the answer it got, and every finding it skipped
with the reason are listed here. Findings are never dropped silently and changes are never guessed.

```markdown
# Plan Cycle Log: [Plan Title]

Started: [YYYY-MM-DD HH:MM:SS]
Plan drafted by: [cycle | user]

---

## Iteration [number]

Findings: [X CONFIRMED, Y UNVERIFIED]
Merged: [count]
Asked: [count]
Not merged: [count]

Merged:

- [Plan chapter title] - [one line on what changed in plan.md]

Asked:

- [Plan chapter title] - [the question put to the user]
  Answer: [what the user chose, and what was written to plan.md as a result]

Not merged:

- [Plan chapter title] - [one line on the finding]
  Reason: [user declined the change | evidence missing | UNVERIFIED and would lose information |
  split recommendation, left for the user]

---

[Repeat for each iteration]

## Summary

- Iterations run: [X of Y]
- Stopped because: [no new findings | iteration limit reached]
- Questions asked: [count, or "none"]
- Open items: [count of findings not merged, or "none"]
```
