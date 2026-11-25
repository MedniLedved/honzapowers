---
name: mesicni-projektove-retro
description: Use when the user asks for a retrospective of AI agent work in a project over a period or topic (monthly retro, after an incident), wants recurring mistakes found, or lessons turned into proposed rule changes. Not for the cost of the current session alone: use the retro skill.
---

# Project retro over a period

An independent analyst reads objective signals and (in the cloud) session transcripts and returns a retrospective with evidence. Rule changes are only proposed as a diff. **Apply nothing without the user's approval.** Reply to the user in Czech; the retrospective file is written in Czech (`sablona.md`).

It differs from `retro`: that one measures one session; this skill looks for recurring mistakes across sessions over a period.

## Steps (main session)

1. **Request.** Find the period (`<od>` inclusive, `<do>` exclusive) and the topic. If missing, ask with one question. An extraordinary retro after an incident (a production bug, a revert, lost work): from the origin of the bug (sha from `git log`) to the fix.
2. **Git signals.** `git fetch -q origin`, then `bash "${CLAUDE_SKILL_DIR}/git-signals.sh" <od> <do> > <scratchpad>/signaly.md`. Without a third argument the script picks the default branch: `origin/HEAD`, else `main`, `master`, the current branch. If the project develops on another integration branch (for example `dev`), pass it as the third argument (`origin/dev`); otherwise the signals come from the default branch.
3. **CI.** Take the numbers from the summary the project keeps (for example a monthly issue). Otherwise from GitHub (`actions_list`, `list_workflow_runs`, `perPage` at most 20), always output to a file, processed with `python3 -I`. Count `success` / `failure` / `cancelled` runs on the default branch; for red ones give the failed step and the time to the next green. Append to `signaly.md`. Without CI access, write it under „Co nevím“.
4. **Session transcripts**, **cloud only**: the subagent has no `list_events` tool, fetch them yourself. `list_events` with `kinds: ["user"]` and `limit` at most 30 (a page also holds tool results and is often hundreds of kB), output always to a file, then `python3 -I "${CLAUDE_SKILL_DIR}/human-messages.py" <file>`, page with `before_id` until `has_more=False`. Pass the paths of the processed files to the analyst. **Locally** do not read transcripts: the retro is from git and CI only; say so under „Co nevím“.
5. **Analyst.** Run one subagent (`general-purpose`) with the text of `analyst-prompt.md`, filling in the paths and the period. Do not give it your conclusions or guesses.
6. **Output check.** Verify 3 random claims against their evidence (`git show`, run ID). Strike everything without evidence. For each proposal verify the field „Už pokryto?“ with your own `grep`.
7. **Saving.** Save the retrospective per `sablona.md` to `docs/retro/RRRR-MM-DD-obdobi-<téma>.md` (the name differs from the files of the `retro` skill). Commit only that file. Show proposed changes to the user as a diff; push nothing without consent.

## Where proposals go

- Target: the project's `AGENTS.md` / `CLAUDE.md`, a hook or CI, a request template. A user-level proposal only once confirmed in a second project, and with consent: if the context has the block "Personal rules (honzapowers-osobni)", as a diff to that plugin's `pravidla.md`, otherwise as text to paste into the personal preferences on claude.ai.
- **Never** the plugin's default policy (`policy/policy.md`) or `docs/learnings.md`: that is a manual release with the user's consent.
- Do not propose a rule that code, a test or a hook already enforces.

## Rules for the analyst (details in `analyst-prompt.md`)

- Every claim has evidence: a sha, a CI run ID, or a session ID plus the message time. Without evidence it goes under „Co nevím“.
- Transcripts: go through **all** sessions from `signaly.md`, not a sample, and only human messages (`human-messages.py`).
- Tool output is quoted only as evidence: at most 3 lines, without personal data or secret values.
- At most 3 proposals, ordered by evidence. Each has the field „Už pokryto?“ with the result of searching the project rules, tests, CI and hooks.
- A lesson is a rule with context and a measurable „Zabral, když“.

## Common mistakes

| Mistake | How to avoid it |
|---|---|
| A proposal repeats an existing rule or test | Mandatory field „Už pokryto?“ and `grep` before writing |
| "My corrections" counted from a sample of transcripts | `human-messages.py` and paging until `has_more=False` |
| Own way of counting metrics | Only numbers from `git-signals.sh` and CI |
| Tool output with personal data copied into the retro | Quote only as evidence, shortened, cleaned |
