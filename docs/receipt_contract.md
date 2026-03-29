# Receipt Contract

## Purpose

This document defines the canonical receipt schema and trace rules for the Coh-Fusion verifier.
It is the single source of truth for what evidence proves and how replay works.

---

## Canonical Receipt Schema

### MicroReceipt (Canonical)

The canonical receipt for single-step transitions:

```lean
structure MicroReceipt (α : Type) where
  statePrev      : State6 α    -- Previous observable state
  stateNext      : State6 α    -- Next observable state  
  spendAuth      : α           -- Authorization spend
  defectDeclared : α           -- Declared defect
```

**Location**: [`src/CohFusion/Core/Receipt.lean`](src/CohFusion/Core/Receipt.lean)

### Fields Explained

| Field | Type | Purpose |
|-------|------|---------|
| `statePrev` | `State6 α` | Previous observable state (Z, vZ, I_act, W, vW, I_cd) |
| `stateNext` | `State6 α` | Next observable state |
| `spendAuth` | `α` | Authorized spend for this step |
| `defectDeclared` | `α` | Declared defect for this step |

### Receipt Decision Context

The receipt alone does NOT contain:
- Decision result
- Reject code
- Threshold values

These are derived from:
- Receipt fields
- Kernel policy (thresholds, defect limits)
- Certificate context

### Alternative Receipts (Non-Canonical)

| Type | File | Status | Notes |
|------|------|--------|-------|
| `BurnReceipt` | `Control/BurnContract.lean` | Adapter | Demo/pipeline variant |
| `HashBoundedReceipt` | `Runtime/HashBoundedReceipt.lean` | Draft | With digest binding |
| `SlabReceipt` | `Core/Receipt.lean` | Draft | Multi-step batch |

---

## State Linkage Policy

### Previous State Link

The receipt binds to the previous state via **full observable representation**:

- `statePrev : State6 QFixed` — Contains all 6 canonical observables
- Not a hash — Full state is directly embedded

### Next State Link

Similarly, `stateNext` contains the full observable representation.

### What This Proves

- The decision was evaluated against these exact state representations
- State linkage is verifiable by reconstructing from receipt fields

### What This Does NOT Prove

- Full plant state (beyond observables)
- Sensor truth beyond declared assumptions
- Internal runtime state

---

## Trace Linkage Policy

### Current State

The repo currently supports:
- `traceLinked` — Checks sequential linkage of receipts
- No canonical trace digest/chaining rule yet

### Chaining Rule (Draft)

```
trace_next = Hash(trace_prev || canonical_receipt_bytes)
```

This rule is **not yet canonical** — needs formalization.

### Recommended Rule

For canonical path:
1. Each receipt commits to previous state (`statePrev`)
2. Trace continuity verified via `traceLinked` check
3. No cryptographic chain digest required for MVP

---

## Certificate Binding

### Current State

Certificate context is NOT currently embedded in receipts.
It is validated separately before kernel evaluation.

### Recommended Fields for Receipt

| Field | Purpose |
|-------|---------|
| `certificateId` | Which certificate authorized this step |
| `regimeId` | Which operating regime applied |
| `certExpiry` | Certificate expiry date used |

### Current Workaround

A checker must:
1. Look up certificate by ID from external context
2. Validate it was valid at decision time
3. Verify regime matches

---

## Replay Semantics

### Replay Procedure

1. **Parse receipt** — Deserialize `MicroReceipt`
2. **Validate state linkage** — `receipt.statePrev` equals expected previous state
3. **Reconstruct kernel inputs** — Extract risk, thresholds, spend from receipt and policy
4. **Recompute decision** — Call `verifyRV_QFixed` with receipt + policy
5. **Verify match** — Recomputed decision equals recorded decision

### Replay Success Criteria

| Criterion | Meaning |
|----------|---------|
| Receipt parses | All fields valid |
| State linkage valid | `statePrev` matches expected |
| Decision matches | Recomputed = Recorded |
| No policy drift | Kernel policy unchanged since issuance |

### What Replay Proves

- The decision was legally computed
- Inputs were consistent with policy
- No tampering occurred

### What Replay Does NOT Prove

- Sensor accuracy
- Physical plant state
- Future certificate validity

---

## Malformed Receipt Handling

### Failure Categories

| Category | Trigger | Kernel Action |
|----------|---------|---------------|
| Schema failure | Unknown version, missing field | REJECT |
| State mismatch | `statePrev ≠ expectedState` | REJECT (unauthorizedTransition) |
| Numeric failure | Parse error, overflow | REJECT (schemaInvalid) |
| Trace failure | `traceLinked = false` | REJECT (stateHashLinkFail) |

### Error Codes

| Code | Meaning |
|------|---------|
| `schemaInvalid` | Malformed receipt structure |
| `unauthorizedTransition` | State linkage failure |
| `stateHashLinkFail` | Trace linkage failure |
| `thresholdExceeded` | Risk exceeds threshold (replay) |
| `defectOutOfBounds` | Defect exceeds limit (replay) |

---

## Receipt Test Vectors

### Nominal Vectors

| Vector | Scenario | Expected |
|--------|----------|----------|
| Safe transition | Risk ≤ threshold, defect ≤ limit | ACCEPT |
| Risk rejection | Risk > threshold | REJECT thresholdExceeded |
| Defect rejection | Defect > limit | REJECT defectOutOfBounds |
| Oplax violation | Descent inequality fails | REJECT oplaxViolation |

### Malformed Vectors

| Vector | Scenario | Expected |
|--------|----------|----------|
| Missing state | `statePrev` absent | REJECT schemaInvalid |
| Invalid state | Malformed `State6` | REJECT schemaInvalid |
| Wrong state | `statePrev ≠ expected` | REJECT unauthorizedTransition |

### Linkage Vectors

| Vector | Scenario | Expected |
|--------|----------|----------|
| Trace break | Receipts not sequential | REJECT stateHashLinkFail |

---

## Proof Scope and Limits

### What the Receipt Proves

- State linkage for the transition
- Decision computation (via replay)
- Numeric evidence values

### What the Receipt Does NOT Prove

- Physical plant state beyond observables
- Sensor accuracy
- Certificate validity (external check required)
- Future transition legality
- Regulatory compliance beyond the wedge

---

## Canonical Path Summary

```
Decision Input → MicroReceipt → Kernel → Decision
        ↑                             
    State6                           Receipt
    Policy                          Replay
    Certificate (external)          
```

The canonical path uses:
- **MicroReceipt** as the canonical receipt
- **State6** for state linkage
- **QFixed** for numeric evidence
- **verifyRV_QFixed** for replay

---

*Last updated: 2026-03-29*
