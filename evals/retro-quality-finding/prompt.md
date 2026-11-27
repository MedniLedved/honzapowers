---
max_turns: 15
timeout_seconds: 300
allowed_tools: [Skill, Read, Glob, Grep, Write, Bash]
runs: 3
---

Do a retro of an earlier session. The session's transcript is `tests/fixtures/transcripts/metrics.jsonl` in the honzapowers plugin directory. One more thing from that session that the transcript does not show: before we ran it against production, an independent reviewer found that the new script `scripts/archive_invoices.py` compared dates in local time instead of UTC, so invoices from the last hour of a day would have been archived a day early. All unit tests passed, because they run in UTC. We fixed it before the production run. Don't change any rules, just propose.
