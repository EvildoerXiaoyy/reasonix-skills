---
name: arch-workflow
description: Three-in-one architecture session — blueprint components & data flow, challenge scope from architecture perspective, and record key decisions as ADR drafts. The first step before /to-prd in the development workflow.
argument-hint: "What feature or system are we architecting?"
---

# Architecture Workflow

The first step in the pipeline. Before writing a PRD, establish architectural context across three dimensions: **blueprint** (what are the pieces), **scope challenge** (are we building the right thing), and **decision capture** (why are we building it this way).

Walk through all three phases. Each phase may be skipped if already settled (e.g. existing ARCHITECTURE.md covers it).

---

## Phase A — Blueprint

### A1. Explore

**For greenfield projects (no existing codebase):** skip A1 and establish the baseline architecture directly in A2.

If a codebase already exists:
- Existing module structure and boundaries
- Existing `ARCHITECTURE.md` or `docs/adr/` for prior decisions
- Key interfaces and seams
- Current data flow patterns

### A2. Interview — one topic at a time

**Topic 1 — System components**
What are the major components or modules? What does each own?

**Topic 2 — Component relationships**
How do components talk? Sync (RPC/gRPC) vs async (event/message queue)? Produce an ASCII interaction diagram.

**Topic 3 — Data flow**
Trace one key end-to-end flow: entry point → processing → storage → response. What data crosses which boundary?

**Topic 4 — External dependencies**
What external systems does this depend on? (DB, queues, third-party APIs, LLM providers). What's the blast radius if each one fails?

**Topic 5 — Fault tolerance & isolation**
What's the fallback strategy when external dependencies timeout or go down? Do we need circuit breakers, retry mechanisms, or bulkheads? How is the blast radius contained?

**Topic 6 — Key constraints**
Performance targets, consistency requirements, compliance, deployment topology, ADRs to respect.

---

## Phase B — Scope Challenge

Challenge the plan scope from an architecture perspective before it enters `/to-prd`:

1. **Minimal architectural change** — what's the smallest set of architectural changes that achieves the goal? Can we reuse existing components instead of building new ones?
2. **Component boundaries** — does the proposed scope respect existing component boundaries, or does it create cross-cutting concerns?
3. **Interface contracts** — if this adds new interfaces, are they general enough to outlive this feature?
4. **Technical debt assessment** — does this plan introduce architectural debt that will need cleanup later?
5. **Observability impact** — does this change impact existing monitoring, tracing, or alerting?
6. **Trust boundaries** — does this change cross different trust domains? Are AuthN/AuthZ handled properly, or does it leave privilege escalation risks?

For each issue found, call AskUserQuestion individually. Present options, state your recommendation, explain WHY.

---

## Phase C — ADR Draft

For each architecturally significant decision surfaced in Phase A or B:

- **Hard to reverse?** (e.g. database choice, API contract, deployment topology)
- **Surprising without context?** (future reader would wonder "why this way?")
- **Result of a real trade-off?** (genuine alternatives existed)

If all three are true, write an **ADR draft** (not just a skeleton) to `docs/adr/`. Use the interview context from Phase A and Phase B to directly fill in Context, Decision, and Consequences — the user has already discussed the trade-offs.

```markdown
# ADR-<NNN>: <title>

## Status

Proposed

## Context

[What constraints and forces led to this decision? What alternatives existed? — drawn from Phase A & B conversation]

## Decision

[What we decided and why]

## Consequences

[What becomes easier, harder, or requires future work]
```

Number sequentially from existing ADRs. Do NOT write ADRs for trivial or self-evident decisions — only the three conditions above justify one.

---

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| Architecture Blueprint | `ARCHITECTURE.md` | Component map, data flow, dependencies, fault tolerance |
| **Formal API Contract** | `API_CONTRACT.yaml` / `API_CONTRACT.ts` | Machine-readable interface definitions — types, methods, signatures |
| **DB Schema** | `DB_SCHEMA.sql` | Key tables, indexes, constraints |
| Module Dependency Map | `MODULE_DEPENDENCY.md` | Dependency order across modules, annotated with ✅ once each passes its gate |
| ADR Drafts | `docs/adr/NNN-title.md` | Key decisions with Context/Decision/Consequences filled in |
| Scope Notes | (inline) | What was challenged and resolved in Phase B |

**`API_CONTRACT.yaml` 格式约定（供 `/test-gen` 和后续 skill 解析）：**
```yaml
# API_CONTRACT.yaml — minimal schema for TDD generators
services:
  user-auth:
    methods:
      - name: Login
        input: { email: string, password: string }
        output: { token: string, expires_at: timestamp }
        errors: [InvalidCredentials, AccountLocked]
```
所有后续 skill（如 `/test-gen`）依赖此格式生成测试骨架。字段含义：`services` 为模块名，`methods` 为公共方法列表，每项包含 `name`、`input`、`output`、`errors`。

## Hand off

Tell the user:
- `ARCHITECTURE.md` has been written/updated
- `API_CONTRACT.yaml` and `DB_SCHEMA.sql` have been generated (formal contracts for TDD)
- `MODULE_DEPENDENCY.md` has been written (dependency order for module loops)
- Any ADR drafts created (Context/Decision/Consequences filled from the conversation)
- Suggested next step: `/to-prd` to turn this context into a formal PRD

**Important:** Confirm module dependency order with the user. Write the agreed order to `MODULE_DEPENDENCY.md` using the format:
```
1. common-utils ✅
2. user-auth (depends on common-utils)
3. order-core (depends on user-auth)
4. payment-gateway (depends on user-auth, order-core)
```
The ✅ markers will be checked by `/dep-status` before each module's TDD loop.

**Contract versioning note:** The generated `API_CONTRACT.yaml` and `DB_SCHEMA.sql` represent the **initial baseline**. Any future amendments should be done via `/amend-contract` to maintain traceability.

**`✅` 语义说明：** 模块名后的 `✅` 表示该模块的**门禁已通过**——即所有单元测试通过 **且** `/codereview --assistant` 无 blocker 问题。未达标前不可标记 `✅`，也不应进入下一模块的开发。
