# Lesson candidates

Used by `retro` and `handover`. Propose; a project skill file only after the user's explicit yes (see § Skill); never write `docs/learnings.md` or rules.

## Test
A lesson is a candidate only if it is all of:
- Reusable: it will recur in another session.
- Non-trivial: it needed discovery, not a documentation lookup.
- Specific: it names a trigger (an error text, a command or a file).
- Verified: this session holds a command and its output as evidence (`line:N` only as an addition).

Drop it if it would not help in six months.

## Existing entry
Search the trigger in this order: the file from the context line `Personal lessons file (read on demand): <path>` the project's `docs/retro/` and `docs/handover/`, then the findings index of the plugin's `docs/learnings.md` (empty means no match).
- No match: new candidate.
- Same trigger, same fix (recorded in an earlier session, never one this session wrote): not a new entry. Say `už je v osobním přehledu, <date>` (never the path of the personal file); pass it to § Skill as a second occurrence (class `project`: second time in the same project; class `general`: confirmed in a second project).
- Same trigger, other cause: new candidate that links the old one.
- Outdated: propose marking the old entry obsolete (no new status).

## Skill
Propose a skill only if all hold: 3 or more steps, or a diagnosis Claude would not do alone; the trigger shows at the start of a task; a second occurrence; no cheaper mechanism (script, test, prohibition); text within 300 words. Otherwise it goes only into the entry. Create a skill file only after the user's explicit yes in this session, class `project` only, at `.claude/skills/<name>/SKILL.md`. For class `general`, propose the text for the personal plugin; never write it.

## Output
At most 3 candidates, or `žádný kandidát` (a valid result). If there are more, keep the 3 with the strongest evidence and add one line with the count (`+2 další vynechány`). Each has: trigger, one-sentence fix, evidence (command and output), class `general`, `project` or `one-off`. Write to the user in Czech.

Nobody writes the personal file automatically: for class `general`, propose the row as a diff of the `Personal lessons file`; the user approves it. An unconfirmed `general` candidate is marked `candidate`, never proposed as a rule. No project names, no user data.
