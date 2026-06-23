---
name: reconcile
description: Compare final implementation against ARCHITECTURE.md, PRD, and ADRs — detect drift, update docs, and close the loop before handoff. Run during the 回顾 phase, after implementation is complete.
argument-hint: "What feature or system to reconcile?"
---

# Reconcile — Spec vs Implementation Drift Detection

Compare the **as-built** code against the **as-designed** docs (ARCHITECTURE.md, PRD, ADRs). Identify three types of drift and produce an actionable report.

## Process

### 1. Read the specs

Read the current state of:
- `ARCHITECTURE.md` — architecture blueprint (components, data flow, dependencies)
- The latest PRD or `docs/prd.md` — feature scope and user stories
- `docs/adr/` — existing architecture decision records
- `TODOS.md` — outstanding tasks from planning phase

### 2. Extract the real code skeleton

Do NOT dump full code into context. Instead, extract a lightweight skeleton:

- **Public interfaces and types** — grep for `type X struct`, `interface X`, `func X` in the relevant packages
- **Dependency graph** — imports between packages (e.g. `package A imports package B`)
- **Data model** — key structs, table schemas, enums
- **Entry points** — main functions, handlers, CLI commands

This skeleton is the **as-built truth**. Keep it concise — a few dozen lines, not the full codebase.

### 3. Detect drift — three dimensions

For each item below, compare the skeleton against the specs and classify:

| Drift Type | Signal | Action |
|-----------|--------|--------|
| **Feature Creep** | Code has interfaces/types/handlers not mentioned in any spec | Flag as warning. Ask: should this become a new ADR, or is it dead code to remove? |
| **Missed Scope** | Spec promises behavior that has no corresponding code path | Generate a missing checklist. Recommend whether to implement or update the spec. |
| **Contract Violation** | Code does it differently than ARCHITECTURE.md says (e.g. spec says Redis, code uses local cache) | If the code is right: update ARCHITECTURE.md + write an ADR. If the spec is right: flag as bug. |

### 4. Produce the drift report

Write to `REconcile-<date>.md` in the project root:

```markdown
# Reconcile Report — <date>

## Summary
- Feature Creep: X items
- Missed Scope: Y items  
- Contract Violations: Z items

## Feature Creep
- `pkg/cache/local.go` — local cache implementation not in ARCHITECTURE.md. Suggestion: add ADR.

## Missed Scope
- PRD §2.3 "rate limiting" — no corresponding code. Suggestion: remove from PRD or implement.

## Contract Violations
- ARCHITECTURE.md says Redis, code uses `pkg/cache/local.go`. Code is simpler & correct for scale. Suggestion: update ARCHITECTURE.md + new ADR.

```

### 5. Next steps (no automatic fix)

**Do NOT automatically modify any code or documentation.** After presenting the report, pause and ask the user to decide on each drift item:

- Should the code be adjusted to match the spec?
- Should the spec be updated to reflect the actual implementation?
- Should a new ADR be created to justify the deviation?

Once the user has made decisions, proceed to update the relevant files only with explicit confirmation.

## Hand off

Tell the user:

- Drift report written to `REconcile-<date>.md`
- No automatic changes were made — human decisions are required
- Suggested next step: manually resolve drift items, then run `/handoff` to pack the context
