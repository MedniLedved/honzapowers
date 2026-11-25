---
name: pre-done
description: Use when about to claim done or open a PR on architectural work, data deletion or a shared interface change (see skilly-kdy-ktery), to have a fresh-context reviewer check the diff and walk UI flows. Not for trivial or docs-only changes.
---

# Pre-done check

Green lint, type checks and unit tests are not a review. In the pilot all
three branches were green and an independent review still found 1 Critical
and 5 Important defects. Run this once, right before "done".

## 1. List what the diff is judged against
- The user's request, in a few bullets (what must be true when done).
- The project's own rules: grep `AGENTS.md` / `CLAUDE.md` for the rules that
  apply to the touched files (gates, forbidden actions, code and DB rules).

## 2. Review in a fresh context
Start one subagent (model Sonnet, effort high) with only: the bullets from
step 1 and the diff command (`git diff <base>...HEAD`). It reads the diff and
the touched files, and returns at most 20 lines: findings as Critical,
Important or Minor, each with `file:line` and one sentence. It must not edit.
Fix Critical and Important findings, then re-run the checks that cover them.
Do not re-run unrelated passed tests.

## 3. UI flows: try the main path
For a stateful editing flow, do one manual or scripted pass of the main path,
typing into every editable field one character at a time, including a
half-typed value. Unit tests of pure functions cannot catch a row that
disappears or saves a partial value.

## 4. Report
In the "done" message: the findings (or "none"), what was fixed, and the
command with its result that proves it. Name anything left unfixed.
