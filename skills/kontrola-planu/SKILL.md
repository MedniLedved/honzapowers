---
name: kontrola-planu
description: Use when a plan file has just been written (writing-plans, docs/plans) and before it is executed, to check it against the spec and project rules with read-only checker agents, sort the findings into fix, ask or reject, and propose a lesson for the project's own criteria file.
---

# Plan check

Check a finished plan before it is executed. The agents only read. You fix the plan, and only where the fix is unambiguous. Reply to the user in Czech.

## 1. Inputs
- Plan: the path from the user, else the newest file in `docs/superpowers/plans/` or `docs/plans/`.
- Source of truth: the request or spec the plan belongs to, the project's `AGENTS.md` / `CLAUDE.md` and the touched code.
- Project criteria: `.claude/kontrola-planu.md`. If the file exists, load it. If not, check with the general criteria below. Offer to create the file once per project (steps 6 and 7); if the user declined it in this project, do not offer it again.

General criteria: every task names files, steps and a verification command; the order of steps makes sense; the plan matches the request (nothing extra, nothing missing); the steps can be done without asking again; result and code are economical.

## 2. Reading list
The agents do not read a large plan or request whole. Prepare a list `file lines X–Y` for them:
- `grep -n "^## \|^### "` in the plan and the request → only the sections the plan refers to;
- for code only the function headers (`grep -n "^def \|^class "` or similar) and the functions the plan changes;
- for `kontrola-souladu`: the plan, project rules, request, criteria; for `kontrola-auditu`: the plan, project rules, the most similar finished code and dependent tasks.

## 3. Threshold and agents
Count the open tasks (`- [ ]`).
- **Up to 3 tasks:** run only the agent `honzapowers:kontrola-souladu`.
- **More than 3:** run `honzapowers:kontrola-souladu` and `honzapowers:kontrola-auditu` **in parallel** in one answer.

Give the agents the reading list from step 2 and one sentence on what the plan does, not the file contents. Each returns at most 5 findings with a bin `OPRAVIT|ZEPTAT|ZAMÍTNOUT`, a severity `kritický|ostatní`, a mark `OVĚŘENO` (with place and quote) or `DOMNĚNKA`, the place in the plan and a one-sentence reason.

If the agents did not load (the plugin is not active), run a general subagent on the sonnet model and give it the body of the agent file as its task.

## 4. Sorting
Merge the findings of both agents, remove duplicates and decide the bins yourself (the agent only proposes):
- **`OPRAVIT`:** the fix is unambiguous and lies in the plan. Fix it now.
- **`ZEPTAT`:** it changes an earlier decision of the user, is a choice between two correct solutions, or lacks a fact only the user knows. Ask all questions **at once**, each with a proposed default answer and one sentence why.
- **`ZAMÍTNOUT`:** the finding does not hold or misses the request. Say why in one sentence.

Verification saves context: verify critical findings and every `DOMNĚNKA` by reading the cited place; accept `OVĚŘENO` non-critical findings without reading if the quote matches the plan. When the agents disagree, a fact from the request or the code wins over economy. You write the text into the plan, not the agent.

## 5. Second round
Only when the fix of a **critical** finding changed an interface, the order of tasks or the scope: run `honzapowers:kontrola-souladu` once more on its own, reading only the `git diff` of the plan (at most 5 findings). Otherwise no second round.

## 6. Lesson for future plans
Propose only a rule that will hold for at least two future plans. Order:
1. Can code, a test or a hook enforce it? Then propose a task, not a rule text.
2. Otherwise the rule as a **unified diff** against the project's `.claude/kontrola-planu.md`, for approval. First merge with or replace an existing point; if the file has more than 15 points, first propose pruning.

Also:
- write nothing without the user's consent;
- never edit the plugin or `policy/policy.md`;
- do not write a rule that code, a test or a hook already enforces;
- if `.claude/kontrola-planu.md` is missing, offer to create it once per project, even with no repeatable rule (then an empty file with a header); never after the user declined; never create it yourself;
- do not prescribe a fixed project command (for example a test command), only that the plan names its verification command.

## 7. Closing
Add to the plan the line `**Stav:** kontrola <datum>: N nálezů, opraveno X, otázky Y, zamítnuto Z.` In a cloud session commit the plan file alone and push it to the task's working branch or the session-assigned branch (the container is lost when the session ends); `main`, a shared or another person's branch stays a gate (G1). Locally do not commit; say the plan is changed. Then write the user at most 6 lines in Czech: the number of findings per bin, what you fixed, what you wait for (questions), whether a second round ran, the proposed lesson and, if the criteria file is missing, the offer to create it (once per project, see step 6).
