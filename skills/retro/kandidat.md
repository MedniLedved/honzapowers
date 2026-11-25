# Lesson candidates

Used by `retro` and `handover`. Propose only; never write a skill file, `docs/learnings.md` or rules.

## Test
A lesson is a candidate only if it is all of:
- Reusable: it will recur in another session.
- Non-trivial: it needed discovery, not a documentation lookup.
- Specific: it names a trigger (an error text, a command or a file).
- Verified: this session holds a command and its output as evidence.

Also ask: would it help in six months? If not, drop it.

## Existing entry
Search the trigger in the findings index of `${CLAUDE_SKILL_DIR}/../../docs/learnings.md` (an empty index means no match) and in the project's `docs/retro/`.
- No match: new row.
- Same trigger, same fix: update that row.
- Same trigger, other cause: new row that links the old one.
- Outdated: propose marking the old entry obsolete (no new status).

## Output
At most 3 candidates, or `no candidate` (a valid result). Each has: trigger, fix in one sentence, evidence (command and output, or `line:N`), class `general`, `project` or `one-off`. A `general` candidate not yet confirmed in a second project is marked `candidate` and is never proposed as a rule. No project names, no user data.
