---
name: handover
description: Use when the user explicitly asks for a handover (or says they are stopping for a fresh session), or said yes to a proposed one, to write a dated handover file with a short retro. Never start it on your own; elsewhere only propose it in one sentence and wait.
---

# Handover

Write one handover file that lets a fresh session continue without this
session's context. Link, do not copy. At most about 700 words.

## 0. Pre-done first
- If the handover will call work done and the code changed since the last
  `pre-done` in this session (or none ran), stop: say so in one sentence,
  propose `pre-done` first, and continue only after its result or the
  user's explicit yes.
- Unfinished work needs no `pre-done`: record it as unfinished, never as done.

## 1. Where it goes
- Look for a handover convention in the project's `AGENTS.md` or `CLAUDE.md`
  (grep for `handover`). Use it if there is one.
- Otherwise: `docs/handover/YYYY-MM-DD-<topic>.md` (today's date, short
  kebab-case topic). Create `docs/handover/` if needed.
- Never create a project `CLAUDE.md` (it would shadow `AGENTS.md`).
- Write in the language the project uses for its docs.
- Create the file with the Write tool, not a shell heredoc: a sandboxed shell can be read-only while Write still works.

## 2. Measure the session (the short retro)
Run once and use only its output; do not read the transcript yourself:

```bash
bash "${CLAUDE_SKILL_DIR}/../../scripts/session-metrics" --session "${CLAUDE_SESSION_ID}" || bash "${CLAUDE_SKILL_DIR}/../../scripts/session-metrics"
```

## 3. Sections
1. **Identity and goal**: project, repo, branch, phase; how the user wants to work (language, phases, approvals) if the project files do not already say it.
2. **Done this session**: each result with its evidence (command and its result, commit, PR link).
3. **Decisions**: what the user approved or rejected, and why; decisions and open items from a Superpowers plan's progress log, carried over before it is deleted.
4. **Open items and gates**: what is unfinished, what waits on the user (credentials, destructive or production steps, pushes to shared or default branches).
5. **Next step**: the concrete first action and its verification command.
6. **Files and reading order**: paths to read first (plan, specs, this file), with section numbers.
7. **Short retro**: 3 to 5 lines of the metrics that matter (context growth, repeated calls, re-runs, largest outputs) and at most 3 findings. Each finding: the metric as evidence, the policy rule ID it touches (`L1`..`G1`) or `new`, and the class `general` (a personal rule, never a change of the plugin policy), `project` or `one-off`. Route a `general` finding only with the user's consent: if the context has a block "Personal rules (honzapowers-osobni)", as a diff to that plugin's `pravidla.md`; otherwise as text to paste into the personal preferences on claude.ai; and only after the same finding was confirmed in a second project. Add `Lessons`: Read `${CLAUDE_SKILL_DIR}/../retro/kandidat.md` and list at most 3 candidates by it, or `no candidate`; evidence required; propose only. For a full analysis, propose the `retro` skill.

## 4. Finish
- No secrets, tokens or keys; no long pastes from logs or files.
- Do not commit or push on your own, even if project rules allow it. Report the path in one line and ask once: "Commit and push the handover? Otherwise it is lost when this session's container ends." (in a cloud session; locally ask only "Commit the handover?") Commit and push only after an explicit yes; pushing still follows the project's git rules.
- Then propose a fresh session (or `/clear`).
