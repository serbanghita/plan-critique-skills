The `execute` skill writes execution state to `[plansFolder]/[selected-plan]/execution-state.json` using
this format.

```json
{
  "planTitle": "[title]",
  "totalSteps": 5,
  "currentStep": 2,
  "completedSteps": [0, 1],
  "skippedSteps": [],
  "failedStep": null,
  "startedAt": "2026-01-12T10:30:00Z",
  "lastUpdated": "2026-01-12T10:35:00Z",
  "stepStartedAt": "2026-01-12T10:35:00Z",
  "gitAvailable": true,
  "gitCommits": [
    {"step": 0, "hash": "abc1234"},
    {"step": 1, "hash": "def5678"}
  ]
}
```
