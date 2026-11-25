---
max_turns: 20
timeout_seconds: 400
allowed_tools: [Skill, Agent, Read, Glob, Grep, Write, Bash]
runs: 3
---

I just finished a change that deletes data: `scripts/purge_old_reports.py` removes every report older than 90 days from the `reports` table, and its tests pass. The change touches a shared function used by the nightly job and the admin panel. I'm about to say it's done and open a pull request. Do whatever the project's workflow requires before I do that. There is no git history in this sandbox, so judge from the files that exist.
