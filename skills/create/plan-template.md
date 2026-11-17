This file defines the template written to `[plansFolder]/[slug]/plan.md` by `create` and the authoring rules
used when an LLM drafts or updates a plan (for example in `cycle`).

During `create`, copy only the code block under `## Template` verbatim with the original plan name in the H1.
When drafting or adding chapters, act as a pragmatic Staff Engineer paired with a ruthless Technical Editor. Never
overwrite or drop user-written requirements, wording, or constraints.

- Staff Engineer: specify Glob-verified file paths, exact symbols, inputs/outputs, edge cases, dependency order,
  and runnable verification. Anchor code references to symbols, headings, or fences instead of fragile line numbers.
- Technical Editor: write a concise, scannable RFC with high signal, declarative bullets, and zero filler,
  throat-clearing, or repetition.

---

## Rules of writing

1. BLUF (Bottom Line Up Front): start each chapter with one sentence stating what changes and why.
2. Bullets over paragraphs: max 1-2 lines per bullet with a plain `Keyword:` lead-in (no bold). Short fenced code
   blocks or type signatures are allowed when exactness requires them.
3. Facts over narrative: state exact behaviors, inputs/outputs, and edge cases; never write hedging like
   "we will need to carefully consider". If research leaves a choice open, ask the user instead of guessing.

---

## Chapter constraints

- Number chapters sequentially (`## 1. [Title]`) as discrete units of work ordered by dependency.
- Keep `Affected files` and `Verification` in every chapter, as required by the working agreement and skill rules;
  `critique` raises a finding when either one is missing.
- Create subchapters (`### 1.1 [Title]`) when needed; include `Affected files` and `Verification` in any
  subchapter that makes code-related changes.
- Tag each affected file with `create | modify | delete`. In `Verification`, state when no test infrastructure
  exists rather than inventing a harness.

---

## Template

```markdown
# [Original plan name with proper casing]

Goal: [1-2 concrete sentences: what changes and why]
Non-goals: [explicitly out-of-scope items, or "none"]

## 1. [Title]

[BLUF: one sentence stating what this chapter changes and why]

- [Behavior: exact inputs, outputs, edge cases, or short fenced code block]

Affected files:

- [path/to/file (create | modify | delete), or "unknown, to be determined during critique"]

Verification:

- [test to write, command to run, expected output, or "no test infrastructure"]
```
