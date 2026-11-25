# honzapowers learnings

The running index of the plugin's improvement loop, kept by the maintainer. The `retro`
skill reads this file for the promotion gate; the user approves every change
to it, like every change to `policy/policy.md`.

## Rule ledger

One row per rule ID in `policy/policy.md`. **Last flagged** is the date of the
last retro that saw a violation or a clear use of the rule; **Retros since**
counts retros that did not mention it. About 10 retros without a flag make the
rule a candidate to move down the ladder (to a skill or a hard rule), not to be
deleted. Rungs: `hard` (hook, deny rule, script), `skill`, `project`, `policy`.

| ID | Rule | Rung | Last flagged | Retros since |
|---|---|---|---|---|
| L1 | Text over images | policy | — | 0 |
| L2 | Read only the needed lines | policy | — | 0 |
| L3 | Trim command output, full log to a file | policy | — | 0 |
| L4 | Batch related commands | policy | — | 0 |
| L5 | Long suites in the background, no polling | policy | — | 0 |
| L6 | Cheapest channel; new credential is a gate | policy | — | 0 |
| L7 | No re-running passed tests without a change | policy | — | 0 |
| L8 | Subagents only for parallel, noisy or review work | policy | — | 0 |
| L9 | Measure before fixing; /clear, /compact, restart | policy | — | 0 |
| L10 | Handover after a cache-expiring break | policy | — | 0 |
| L11 | Plans name files, steps, verification | policy | — | 0 |
| L12 | CLAUDE.md/AGENTS.md under 200 lines | policy | — | 0 |
| L13 | "Done" shows evidence | policy | 2026-11-10 (evidence was lint/tsc/tests only; an independent review still found defects) | 0 |
| L14 | Short step reports | policy | — | 0 |
| S1 | Inline executing-plans by default | policy | 2026-11-10 (inline `executing-plans`, no agents) | 0 |
| S2 | Work classes; kontrola-planu after writing-plans | policy | — | 0 |
| S4 | Worktrees only locally; project git rules win | policy | — | 0 |
| S5 | Ledger rulings into the handover | policy | — | 0 |
| S6 | Visual companion only on request | policy | — | 0 |
| V1 | Visible skill use (🧩 line, "Použité skilly") | policy | — | 0 |
| F1 | Fallback flow without Superpowers | policy | — | 0 |
| G1 | Stop-and-ask gates | policy | — | 0 |

## Findings index

One row per retro finding that is general, or that recurs. The promotion gate:
a general rule is proposed only when the same finding appears in at least 2
sessions or 2 projects (grep this table and the projects' `docs/retro/`).

| Date | Project | Finding (short, metric) | Rule | Class | Status | Retro |
|---|---|---|---|---|---|---|

