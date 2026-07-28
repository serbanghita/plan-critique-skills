The `execute` skill writes the execution log to `[plansFolder]/[selected-plan]/execution-log.md` using
this format.

```markdown
# Execution Log: [Plan Title]

Started: [YYYY-MM-DD HH:MM:SS]

---

## Step 1: [Step description]

Result: [COMPLETED | FAILED | SKIPPED]
Duration: [Xm Ys]
Files changed: [list of file paths, or "none"]

Output:
[relevant output, changes made, or error messages]
[for FAILED steps, include the actual error output verbatim]

---

## Summary

- Total steps: [X]
- Completed: [Y]
- Failed: [Z]
- Skipped: [W]
- Git commits: [list of commit hashes, or "none"]

[If failed or partial:]
Execution stopped at step [N]. Run `/plan:execute` to resume.
```
