# honzapowers

> Původně vznikl jako `lean-workflow`; proměnné `LEAN_WORKFLOW_*` dál fungují jako záloha k `HONZAPOWERS_*`.

A Claude Code plugin that keeps sessions lean and continuous.

| Component | What it does |
|---|---|
| `SessionStart` hook | Injects a short standing policy (lean-ops rules `L1`–`L14`, Superpowers steering `S1`–`S6`, skill visibility `V1`, fallback `F1`, gates `G1`) and a compact repo state: branch, newest plan with its open-task count, latest handover, a suggested next step. Paths and counts only, never file contents. |
| `UserPromptSubmit` hook | Reads the context size from the transcript's last `usage` record. At 250k tokens, then every +50k, it adds one note asking to propose `pre-done` and then the `handover` skill, running nothing until the user answers. Overrides: `LEAN_WORKFLOW_HANDOVER_TOKENS`, `LEAN_WORKFLOW_HANDOVER_STEP`. |
| `PreCompact` hook | Tells compaction to keep the last verification result, open approval gates and task state. |
| Skill `handover` | Writes a dated handover (project convention, default `docs/handover/YYYY-MM-DD-<topic>.md`) with a short retro. Runs only on the user's request or yes; checks for `pre-done` first and commits only after consent. |
| Skill `kontrola-planu` | Checks a written plan before execution with read-only agents `kontrola-souladu` and `kontrola-auditu` (the second only for plans over 3 tasks); sorts findings into fix, ask, reject and proposes a lesson for the project's `.claude/kontrola-planu.md`. |
| Skill `skilly-kdy-ktery` | Work classes and the standard skill path, with when `pre-done`, `retro` and `handover` are due. |
| Skill `mesicni-projektove-retro` | Retrospective of a project over a period: objective git signals (`git-signals.sh`), CI numbers and, in the cloud, the user's own messages from session transcripts (`human-messages.py`); an independent analyst proposes at most 3 rule changes with evidence. Never edits the default policy. |
| Skill `retro` | Measures the session with `scripts/session-metrics` and proposes at most 5 classified findings (rule ID, general/project/one-off, rule-ladder rung). Never edits rules. |
| Agent `log-reader` | Haiku; reads a long log and returns the verdict and failing lines (≤ 30 lines). |
| `scripts/session-metrics` | ≤ 30 lines of numbers from a transcript: context growth, tokens, tool calls, repeated commands, test re-runs, large outputs. No transcript content. |

Rule ledger and findings index: [`docs/learnings.md`](docs/learnings.md).

Design and roadmap: [`docs/plan.md`](docs/plan.md).

## Install

On claude.ai: Customize → Plugins → Add → **Add marketplace** → `MedniLedved/honzapowers`, turn on **Sync automatically**, then enable `honzapowers`. It syncs to the PC terminal and to cloud sessions.

In a terminal without account sync:

```bash
/plugin install honzapowers --marketplace MedniLedved/honzapowers
```

## Rollback

Disable the plugin on claude.ai, or set `"honzapowers@synced": false` in your settings. Nothing else needs removing.

## Development

```bash
bash tests/run-tests.sh
```

```bash
claude plugin validate --strict .
```

```bash
claude --plugin-dir . plugin details honzapowers
```

```bash
bash scripts/session-metrics path/to/transcript.jsonl
```

Eval cases live in `evals/` (skill triggering, with a no-plugin baseline arm). Running them starts real agent sessions on your account (3 cases × 3 runs × 2 arms):

```bash
claude plugin eval . --allow-tools Write Edit Bash --max-cost-usd 5
```

CI only checks that the cases load (`--max-cost-usd 0`, no agent runs).

Hooks are extensionless bash scripts run through `hooks/run-hook.cmd`, so they work on Windows with Git Bash. Shared helpers live in `hooks/lib/`. Hooks always exit 0, stay read-only (except the per-session state file in `${CLAUDE_PLUGIN_DATA}`), use no network and no `jq`.
