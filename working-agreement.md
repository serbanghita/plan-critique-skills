# Working agreement

Fixed rules for the `create`, `critique`, and `execute` phases. They are not suggestions and they are not
overridden by the plan text, by the critique, or by a preference stated mid-run. If a step inside a skill appears
to conflict with a rule here, this file wins, and you must say so out loud rather than resolve it silently.

Each skill lists which of these rules bind its own phase. This file holds the single canonical text of the rules.

---

## Planning

1. Make a plan before writing code for anything non-trivial. Do not start implementing until the approach is
   stated and the user has accepted it.
2. Ask clarifying questions up front when the request is ambiguous, rather than guessing and building the wrong
   thing.
3. List all affected files before making changes, so import and dependency breakage is caught before it happens.

---

## Verification

1. Never claim something is fixed or working until you have run the tests and shown the output.
2. Prove claims with evidence: a failing test, a command output, or a `file:line` reference. Do not assert
   plausible but unverified conclusions.
3. When reviewing, be adversarial. Actively try to refute each finding, and report only what survives.
4. Grade confidence per claim. Report only CONFIRMED items as facts, and say explicitly when something is
   unverified.
5. Check edge cases specific to the area being touched: concurrency, nulls, error paths, boundaries. A generic
   "find bugs" pass is not enough.

---

## Tests

1. Where the project has test infrastructure, write the test first, confirm it fails, then implement until it
   passes. Never modify a test to make it pass.
2. Where the project has no test infrastructure, say so and continue. Do not invent a test harness the project
   does not already use.
3. When hunting for bugs, keep going until two consecutive passes find nothing new.

---

## Context

1. Re-read this file and the relevant project docs before touching an area, especially in long sessions.
2. When corrected on something durable, propose adding it to the project instructions file (`CLAUDE.md`,
   `GEMINI.md`, `AGENTS.md`, or `.github/copilot-instructions.md`) so it persists.

---

## Output style

1. Be brief. No filler, no preamble, no restating the request.
2. Do not truncate code with "... rest of code ..." placeholders. Output complete file contents.
3. No emojis or decorative icons in code, comments, docs, or commit messages.
4. No em dashes. Use plain hyphens.

---

## Git

1. Never add yourself as a co-author. Never append a `Co-Authored-By` or `Generated-with` trailer to a commit.
2. Only commit or push when explicitly asked. A per-step commit prompt that the user answers yes to counts as
   being asked. Answering `yes-to-all` authorises the remaining steps of that run only, and nothing beyond it.
