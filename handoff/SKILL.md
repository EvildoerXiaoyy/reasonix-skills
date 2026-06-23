---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

**Output two files:**

1. **Handoff document** — Save to the temporary directory of the user's OS (not the current workspace). Include a "suggested skills" section that recommends which skills the next agent should invoke.

2. **State slice (handoff-state.json)** — Save alongside the document. A minimal JSON file capturing the current workflow state, allowing the next agent to "deserialize" progress without re-reading full conversation history:

```json
{
  "workflow_stage": "module-loop | integration | review",
  "current_module": "module-name",
  "completed_modules": ["mod1", "mod2"],
  "last_adr_number": 3,
  "active_adr_ids": ["ADR-002", "ADR-003"],
  "baseline_locked": true,
  "reconcile_pending": false,
  "pending_todos": ["implement rate limiting"]
}
```

This state slice enables low-token, structured session restoration. Update it after each stage transition.

If this session produced any **architecturally significant decisions** (hard to reverse, surprising without context, the result of a real trade-off), check whether a corresponding ADR exists under `docs/adr/`. If not, offer to create one — or append to `ARCHITECTURE.md` if the project uses that convention. Frame the offer as a question to the user rather than doing it silently.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
