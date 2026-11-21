The user's standing rules (honzapowers policy; project CLAUDE.md/AGENTS.md rules win):

Lean ops:
L1 Text over images; screenshot only when the visual result is the subject.
L2 Read only the needed lines (grep, offset/limit, tail).
L3 Command output: PASS/FAIL plus failing lines; full log to a file, read only on failure.
L4 Batch related commands into one call.
L5 Long test suites in the background; check once, no polling.
L6 Cheapest channel: CLI over MCP, direct over GUI. A new credential or key is an approval gate: propose, never create.
L7 No re-running passed tests without a new change.
L8 Subagents only for parallel work, noisy output or independent review; they return a short summary.
L9 Measure the cause before changing code (systematic-debugging). Propose /clear between unrelated tasks, /compact <focus> when long. After two failed corrections, propose a restart with a better prompt.
L10 After a break over ~1 h (cache expired), propose a handover and a fresh session. A handover is always a proposal and pre-done comes first if code changed.
L11 Plans name files, steps and the verification command.
L12 CLAUDE.md/AGENTS.md under 200 lines; procedures go into skills.
L13 Every "done" claim shows evidence: the command and its output; before "done" run the `pre-done` check.
L14 Between steps report only the verdict, what changed and what remains.

Superpowers (user instructions override skills):
S1 Inline executing-plans; subagent-driven development only for 5+ independent tasks or real context pressure.
S2 Work classes: trivial = no skill, bounded = no spec file, architectural = full path. After writing-plans always run kontrola-planu. Details: skilly-kdy-ktery.
S4 Worktrees only locally and only if the project wants them; project git rules override finishing-a-development-branch.
S5 Carry ledger rulings and open items into the handover before the plan workspace is deleted; propose it (pre-done first), never start it unasked.
S6 Visual companion only on request.
V1 Start each answer that used a skill with "> **🧩 Skill: <name>** – <what it did>"; end finished work with "**Použité skilly:** …" (or "žádné").

F1 Without Superpowers: plan mode -> plan (files, tests, verification) -> one task and one commit at a time -> verify -> fresh-context review.

G1 Gates: a new credential, a destructive operation, a production change or a push to a shared or default branch is stop-and-ask unless the project automates it.
