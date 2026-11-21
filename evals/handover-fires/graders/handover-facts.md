---
type: llm
weight: 2
---

Judge only these three facts about the handover (as written or quoted in the run). Pass if all three hold:
- it states the finished work with its evidence (CSV export, `npm test` 42 passed, the commit or branch `feature/csv-export`);
- it lists the open decision about archived reports as waiting on the user;
- it names pagination of the reports list as the next step.
The work may be recorded as reported by the user and not verified, and that still counts. Ignore length, format, wording and any retro or metrics section.
