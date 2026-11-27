---
name: retro
description: Use when the user asks for a retro, a session review, or an analysis of why a session was slow, expensive or token-heavy, to measure it with session-metrics and propose classified, evidence-backed improvements without changing any rules.
model: sonnet
---

# Retro

Turn measured session numbers into at most 5 improvement proposals. The script
measures; you interpret about 30 lines. Never change rules yourself.

## 1. Measure
```bash
bash "${CLAUDE_SKILL_DIR}/../../scripts/session-metrics" --session "${CLAUDE_SESSION_ID}" || bash "${CLAUDE_SKILL_DIR}/../../scripts/session-metrics"
```
For a past session the user names, pass its transcript path instead. Do not
read the transcript. Only if a number alone does not explain the cause, look
at no more than 3 referenced lines (`sed -n '<N>p' <transcript> | cut -c1-300`)
and do not quote their content in the retro.

## 2. Findings (at most 5)
For each finding give:
- **Evidence**: the metric with its number and `line:N`.
- **Rule**: the policy rule ID it violates or uses (`L1`..`L14`, `S1`, `S2`, `S4`..`S6`, `V1`, `F1`, `G1`; see `${CLAUDE_SKILL_DIR}/../../policy/policy.md`) or `new`.
- **Class**: `general` (would hold in every project of this user: a personal rule, never a change of the plugin's default policy), `project` (this repo only) or `one-off` (record only).
- **Rung**: where the fix goes, cheapest first: `hard` (hook, deny rule or script, 0 context tokens; a hookify rule only if the hookify plugin is installed), `skill`, `project` (`AGENTS.md`/`CLAUDE.md` line), `policy`. Say in one clause why it cannot go on a cheaper rung.
- **Proposal**: the exact text or script to add, or the rule to rephrase.

## 2b. Candidates
After the findings, Read `${CLAUDE_SKILL_DIR}/kandidat.md` and apply it to what the session learned.
Report at most 3 candidates or `žádný kandidát`.
Propose only. Write a project skill file only after the user's explicit yes in this session, as `kandidat.md` § Skill says; never write `docs/learnings.md` or rules.

## 3. Promotion gate
A `general` finding becomes a proposal only if the same finding was already
confirmed in a second project. Check:
- `grep -ri '<keyword>' docs/retro/` in this project;
- the findings index in `${CLAUDE_SKILL_DIR}/../../docs/learnings.md`;
- the file named in the `Personal lessons file` line of the context, if present.

Otherwise mark it `candidate` and keep it out of the policy. The policy is
capped at 3,200 characters: a new rule must fit or replace, merge or shorten
another one.

## 4. Save and report
- Save `docs/retro/YYYY-MM-DD-<topic>.md` in the project: the metrics block, the findings, and a line `Rules flagged: <IDs>` (policy rule IDs), and a section `Kandidáti na poznatek` (the candidates or `žádný kandidát`) so the next duplicate search finds them.
- Never edit `policy/policy.md`, `docs/learnings.md`, `AGENTS.md` or `CLAUDE.md` in this step. Changes go only with the user's consent:
  - `project` finding: a diff or PR in the project;
  - `general` finding: if the context has a block "Personal rules (honzapowers-osobni)", propose a diff to `pravidla.md` of that personal plugin; otherwise give the text to paste into the personal preferences on claude.ai. A `general` finding is proposed only after the same finding was confirmed in a second project;
  - never a change of the default policy of honzapowers: that is a manual release with the user's consent.
- Report in a few lines: the findings, the lesson candidates and which proposals are ready for a PR. Ask which to open.
