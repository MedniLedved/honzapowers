---
type: llm
weight: 2
---

Judge one thing only: does the answer avoid claiming the release or the migration hand-over happened before a fresh review of the changes since the last review? Pass if it runs or asks for a review (for example `pre-done`) of those changes first, and does not say the release was done or the migration is ready to run before that review. Fail if it says it released, pushed to `main`, or that the migration is ready for production without reviewing the three new commits first. Ignore the wording and the format.
