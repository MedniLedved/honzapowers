---
name: skilly-kdy-ktery
description: Use when starting a task and deciding which skills to run and in what order, when the policy rule S2 or V1 is in play, or when unsure whether pre-done, retro or handover is due. Gives the work classes, the standard path and when each step is mandatory.
---

# Skills: when and which

Details for the policy rules S2 and V1. You run skills yourself as the situation calls for them; the user does not have to think of them. At the start of a task, say in one sentence which path you take, and do not mention the steps you skip. Gates and rules of the project in `AGENTS.md` / `CLAUDE.md` win. Reply to the user in Czech.

## 1. Work class
- **Trivial** (typo, small fix, documentation): no skills, only verification.
- **Bounded** (clear scope, finished request): plan → plan check → execution.
- **Architectural** (a new part of the system, a schema change, unclear *what*): first `superpowers:brainstorming`, then the full path.

When unsure about the class, pick the higher one.

## 2. Path
`superpowers:brainstorming` (architectural only) → `superpowers:writing-plans` → `kontrola-planu` → `superpowers:executing-plans` (inline; subagents only for 5 or more independent tasks) → `superpowers:verification-before-completion` → `honzapowers:pre-done` → (`honzapowers:retro`) → `honzapowers:handover`.

## 3. When each step is mandatory
- **`kontrola-planu`:** after every `writing-plans`, before the first line of code. Not for trivial work.
- **`verification-before-completion`:** always before claiming "done", before a commit and a PR: show the command and its output. Do not re-run passed tests without a new change.
- **`pre-done`:** for architectural work and for a change that deletes or overwrites data or changes a shared interface. For other changes only on request or when the project requires it. It comes before a handover if code changed.
- **`retro`:** only when the session was slow, expensive or went in circles, or on request. Always before a handover that mentions it.
- **`handover`:** end of the session, before `/clear`, with a large context or after a break of over an hour. **Never start it yourself**: propose it in one sentence ("`pre-done` and then a handover" if code changed) and wait for an explicit "yes". Commit and push the handover only after another yes.

## 4. Error or unexpected result
First `superpowers:systematic-debugging`; fix only after the cause is measured. After two failed fixes, propose a fresh start with a better prompt.

## 5. Visibility (V1)
A skill you used must be visible in the answer, so the user does not have to ask for it again:
- at the very start of the answer a separate line `> **🧩 Skill: <name>** – <what it did, one sentence>`, one line per skill if there are several;
- when you sum up finished work, add the line `**Použité skilly:** …` (or `žádné`).
