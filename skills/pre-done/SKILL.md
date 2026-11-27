---
name: pre-done
description: Use when about to claim done, open a PR or take an irreversible step (production release, migration) on architectural work, data deletion or a shared interface change (see skilly-kdy-ktery), to have a fresh-context reviewer check the diff and walk UI flows. Not for trivial or docs-only changes.
---

# Pre-done check

Green lint, type checks and unit tests are not a review: an independent
review of fully green branches still finds Critical and Important defects. Run this once, right before "done", a PR or an irreversible step. Before an irreversible step after an earlier `pre-done`, review only the diff since the last `pre-done` (`<base>` = the commit it reviewed).

## 1. List what the diff is judged against
- The user's request, in a few bullets (what must be true when done).
- The project's own rules: grep `AGENTS.md` / `CLAUDE.md` for the rules that
  apply to the touched files (gates, forbidden actions, code and DB rules).

## 2. Review in a fresh context
Start one subagent (model Sonnet, effort high) with only: the bullets from
step 1 and the diff command (`git diff <base>...HEAD`). It reads the diff and
the touched files, and returns at most 20 lines: findings as Critical,
Important or Minor, each with `file:line` and one sentence. It must not edit. Ask it to look first for silent failures (a swallowed error, a broad catch, a fallback that hides a failure) and for changed behaviour that no test exercises; this adds no lines to its answer.
For each Critical or Important finding: first add a test that fails because of the finding,
in the project's own way of testing (if no test can show it, e.g. wording or config, say so).
Then fix it, see that test pass, and commit the fix on its own if the session commits
(the project's git rules win). Then run at most one re-review, on the fix changes only
(their commits, or `git diff` of the files the fixes touched); report what is left and
never start a third round.
Do not re-run unrelated passed tests.

## 3. UI flows: try the main path
For a stateful editing flow, do one manual or scripted pass of the main path,
typing into every editable field one character at a time, including a
half-typed value. Unit tests of pure functions cannot catch a row that
disappears or saves a partial value.

## 4. Report
In the "done" message: the findings (or "none"), what was fixed, and the
command with its result that proves it. Name anything left unfixed.
