---
name: adr
description: Capture architecture decisions that emerge during implementation — extract micro-architecture context, apply quality gates, and write formal ADR drafts. Use when you make a non-trivial design choice while coding, or during the 回顾 phase to backfill decisions.
argument-hint: "What architecture decision did you make, or what code should we extract a decision from?"
---

# ADR — Architecture Decision Record

Architecture decisions happen at two moments:
- **During planning** (covered by `/arch-workflow` Phase C)
- **During implementation** — you hit a real trade-off while coding (e.g. trace ID propagation, concurrency model, cache strategy). These are the most valuable ADRs because they reflect **actual system complexity**, not theoretical design.

This skill is for the second case: **extracting decisions from implementation and formalizing them as ADRs.**

## Quality Gate — Should This Be an ADR?

Before writing, check the three thresholds. **All three must be true:**

| Threshold | Question | Example Pass | Example Fail |
|-----------|----------|-------------|-------------|
| **Crosses component boundary** | Does this decision affect other modules, services, or teams? | Trace ID format requires all downstream services to parse it | A local function's error handling strategy |
| **Affects NFR** | Does this impact performance, reliability, security, or operability? | Introducing a distributed lock affects throughput | Choosing ArrayList over LinkedList in an internal loop |
| **Introduces new dependency** | Does this add a new library, service, or infrastructure? | Adding Redis for distributed locking | Using stdlib `sync.Mutex` |

If fewer than three pass: **don't write an ADR.** Instead, put the rationale in an inline comment next to the code. That's enough.

If all three pass: proceed to Phase A.

---

## Phase A — Extract Context

If the user describes the decision verbally, capture it directly.

If extracting from code, do NOT dump full files. Instead:
1. Identify the relevant function/type signature
2. Note the constraint that forced the decision (e.g. "we needed cross-goroutine cancellation")
3. Note the alternatives that were implicitly or explicitly rejected

## Phase B — Write the ADR Draft

Write to `docs/adr/NNN-title.md`, numbering sequentially from existing ADRs:

```markdown
# ADR-<NNN>: <title>

## Status

Proposed

## Context

[What specific code-level constraint forced this decision? What alternatives existed? Be concrete — reference the relevant file/type/function.]

## Decision

[What we did, and why it was the best choice given the constraint.]

## Consequences

[What becomes easier, harder, or requires future work. Include any performance or operability impact.]
```

## Phase C — Cross-Reference (optional)

If the decision overrides something in `ARCHITECTURE.md`, flag it — the `/reconcile` step will catch it automatically, but it helps to note it early.

## Hand off

Tell the user:
- ADR written to `docs/adr/NNN-title.md`
- Whether this decision should affect ARCHITECTURE.md
- Suggested next step: continue coding, or if done, run `/reconcile`
