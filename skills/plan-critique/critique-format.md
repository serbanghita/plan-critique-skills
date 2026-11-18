This is the format the `plan-critique` skill uses when writing `[plansFolder]/[selected-plan]/critique.md`.

Every issue carries a `Confidence`, 1-10 grades (per `Grading findings` in `SKILL.md`), and an `Evidence` line, as
required by the working agreement. Use CONFIRMED only when the issue was verified against the codebase. Use
UNVERIFIED otherwise, and say what could not be checked.

```markdown
# [Title extracted from first H1 in plan.md, or "Untitled Plan"]
> Keywords: [auto-generated comma-separated keywords based on plan content]  
Iteration: [number]

## Summary

[Brief overview of the plan and overall assessment. Only use bullets, no formatting.]
[State the CONFIRMED count and the UNVERIFIED count.]
[If no language server / LSP was available during this run, state that symbol verification used the Grep fallback.]

---

## [Plan chapter title or Plan chapter title - specific issue]

Confidence: [CONFIRMED | UNVERIFIED] ([1-10]/10)
Priority: [1-10]/10
Complexity: [1-10]/10
Blast radius: [1-10]/10
Ambiguity: [1-10]/10
Verification: [1-10]/10

Description:    
[Clear, concise summary of the issue]

Evidence:    
[The `file:line` reference, command output, or failing test that proves the issue.
For UNVERIFIED, state instead what could not be checked and why.]

Suggested Solution:    
[Suggested fix with all pertinent details]

    ```[language]
    [code block only if applicable, be brief]
    ```

---

[Repeat for each issue found]

[If no issues found:]
No issues found. Plan is ready for execution via `/plan-execute`.
```
