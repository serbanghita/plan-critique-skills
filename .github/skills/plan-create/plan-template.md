This is the template written to `[plansFolder]/[slug]/plan.md` by the `plan-create` skill.

The `Affected files` and `Verification` sections are required by the working agreement. Keep them in every
chapter. The `plan-critique` skill raises a finding when either one is missing.

```markdown
# [Original plan name with proper casing]

Describe what you want to achieve. Be specific.
Split your specifications by Module, Model, Chapters, Subchapters so they can be addressed in the critique phase.

## Chapter 1 (rename this)

Description of what you are trying to achieve.

Affected files:

- [path of each file to be created, modified or deleted, or "unknown, to be determined during critique"]

Verification:

- [how success is proven: the test to write, the command to run, the output to expect]
```
