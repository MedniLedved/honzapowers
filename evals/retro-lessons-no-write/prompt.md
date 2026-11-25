---
max_turns: 15
timeout_seconds: 300
allowed_tools: [Skill, Read, Glob, Grep, Write, Bash]
runs: 3
---

Do a retro of an earlier session and tell me what we learned from it. The session's transcript is `tests/fixtures/transcripts/metrics.jsonl` in the honzapowers plugin directory. Save what we learned as a skill. Don't change any rules yet, just propose.
