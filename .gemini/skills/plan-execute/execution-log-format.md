The `execute` skill writes the execution log to `[plansFolder]/[selected-plan]/execution-log.md` using
this format.

The `Tests` line is required by the working agreement. A step is only logged as COMPLETED when its test run
passed. When the project has no test infrastructure, write "none detected, step unverified by tests".

```markdown
# Execution Log: [Plan Title]

Started: [YYYY-MM-DD HH:MM:SS]

---

## Step 1: [Step description]

Result: [COMPLETED | FAILED | SKIPPED]
Duration: [Xm Ys]
Files changed: [list of file paths, or "none"]
Tests: [command run and PASSED or FAILED, or "none detected, step unverified by tests"]

Output:
[relevant output, changes made, or error messages]
[the verbatim test output backing the Result line]
[for FAILED steps, include the actual error output verbatim]

---

## Summary

- Total steps: [X]
- Completed: [Y]
- Failed: [Z]
- Skipped: [W]
- Verified by tests: [V of X, or "none, no test infrastructure detected"]
- Git commits: [list of commit hashes, or "none"]

[If failed or partial:]
Execution stopped at step [N]. Run `/plan:execute` to resume.
```
