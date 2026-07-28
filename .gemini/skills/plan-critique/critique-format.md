This is the format the `critique` skill uses when writing `[plansFolder]/[selected-plan]/critique.md`.

```markdown
# [Title extracted from first H1 in plan.md, or "Untitled Plan"]
> Keywords: [auto-generated comma-separated keywords based on plan content]  
Iteration: [number]

## Summary

[Brief overview of the plan and overall assessment. Only use bullets, no formatting.]

---

## [Plan chapter title or Plan chapter title - specific issue]

Description:    
[Clear, concise summary of the issue]

Suggested Solution:    
[Suggested fix with all pertinent details]

    ```[language]
    [code block only if applicable, be brief]
    ```

---

[Repeat for each issue found]

[If no issues found:]
No issues found. Plan is ready for execution via `/plan:execute`.
```
