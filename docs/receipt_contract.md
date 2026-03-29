# Receipt Contract

## Purpose

This document defines the canonical receipt schema and trace rules for the Coh-Fusion verifier.
It is the single source of truth for what evidence proves and how replay works.

**Revision**: This version introduces **FusionReceipt** as the unified canonical type, deprecating MicroReceipt, SlabReceipt, and HashBoundedReceipt.

---

## Unified Receipt Schema: FusionReceipt

The canonical unified receipt type combining all receipt variants:

```lean
structure FusionReceipt (α : Type) where
  schemaId      : String          -- Schema identifier
  version       : Nat             -- Schema version
  statePrev     : State6 α        -- Previous state (linkage)
  stateNext     : State6 α        -- Next state (transition)
  spendAuth     : α               -- Authorization spend
  defectDeclared : α             -- Declared defect
  stepCount     : Nat             -- Step count (1 for single-step, >1 for batch)
  digest        : Option Digest    -- Optional chain binding digest
  policyId      : Option String   -- Policy reference identifier
  canonId       : Option String  -- Canon/certificate reference
  prevClaim     : Option Digest -- Previous receipt claim (hash linking)
  nextClaim     : Option Digest -- Next receipt claim (for chaining)
```

**Location**: [`src/CohFusion/Core/Receipt.lean`](src/CohFusion/Core/Receipt.lean)

### Fields Explained

| Field | Type | Purpose |
|-------|------|---------|
| `schemaId` | `String` | Unique identifier for receipt schema version (e.g., "commercial_wedge") |
| `version` | `Nat` | Schema version for compatibility tracking |
| `statePrev` | `State6 α` | Previous observable state (Z, vZ, I_act, W, vW, I_cd) |
| `stateNext` | `State6 α` | Next observable state |
| `spendAuth` | `α` | Authorized spend for this step/batch |
| `defectDeclared` | `α` | Declared defect for this step/batch |
| `stepCount` | `Nat` | Number of steps (1 for single-step, >1 for telescoping/batch) |
| `digest` | `Option Digest` | Optional digest/hash for cryptographic chain binding |
| `policyId` | `Option String` | Reference to kernel policy used |
| `canonId` | `Option String` | Reference to certificate/canon authorization |
| `prevClaim` | `Option Digest` | Hash linking to previous receipt in trace |
| `nextClaim` | `Option Digest` | Claim hash for next receipt in trace |

### Conversion Functions

- `FusionReceipt.ofMicroReceipt` — Convert MicroReceipt to FusionReceipt
- `FusionReceipt.ofSlabReceipt` — Convert SlabReceipt to FusionReceipt

---

## Legacy Receipt Types (Deprecated)

### MicroReceipt

```lean
@[deprecated "Use FusionReceipt instead"]
structure MicroReceipt (α : Type) where
  statePrev      : State6 α    -- Previous observable state
  stateNext     : State6 α    -- Next observable state  
  spendAuth    : α           -- Authorization spend
  defectDeclared : α        -- Declared defect
```

### SlabReceipt

```lean
@[deprecated "Use FusionReceipt instead"]
structure SlabReceipt (α : Type) where
  statePrev      : State6 α   -- Previous state
  stateNext     : State6 α    -- Next state
  totalSpend   : α           -- Total spend for batch
  totalDefect  : α           -- Total defect for batch
  stepCount   : Nat         -- Number of steps
```

### HashBoundedReceipt

```lean
@[deprecated "Use FusionReceipt with digest field instead"]
structure HashBoundedReceipt (α : Type) where
  receipt : FusionReceipt α
  digest  : Digest
```

---

## Deprecated Type Status

| Type | File | Status | Replacement |
|------|------|--------|--------------|
| `MicroReceipt` | `Core/Receipt.lean` | Deprecated | Use `FusionReceipt` |
| `SlabReceipt` | `Core/Receipt.lean` | Deprecated | Use `FusionReceipt` with `stepCount > 1` |
| `HashBoundedReceipt` | `Runtime/HashBoundedReceipt.lean` | Deprecated | Use `FusionReceipt` with `digest` field |

---

## Receipt Decision Context

The receipt alone does NOT contain:
- Decision result
- Reject code
- Threshold values

These are derived from:
- Receipt fields
- Kernel policy (thresholds, defect limits)
- Certificate context

---

## State Linkage Policy

### Previous State Link

The receipt binds to the previous state via **full observable representation**:

- `statePrev : State6 QFixed` — Contains all 6 canonical observables
- Not a hash — Full state is directly embedded

### Next State Link

Similarly, `stateNext` contains the full observable representation.

---

## Trace Linkage Policy

### Current State

The repo currently supports:
- `traceLinked` — Checks sequential linkage of receipts

### Chain Binding (Optional)

For cryptographic chain binding, use the `digest` field:

```
trace_next = Hash(trace_prev || receipt_bytes)
```

---

## Replay Semantics

### Replay Procedure

1. **Parse receipt** — Deserialize `FusionReceipt`
2. **Validate state linkage** — `receipt.statePrev` equals expected previous state
3. **Reconstruct kernel inputs** — Extract risk, thresholds, spend from receipt and policy
4. **Recompute decision** — Call `verifyRV` with receipt + policy
5. **Verify match** — Recomputed decision equals recorded decision

### Replay Success Criteria

| Criterion | Meaning |
|-----------|---------|
| Receipt parses | All fields valid |
| State linkage valid | `statePrev` matches expected |
| Decision matches | Recomputed = Recorded |
| No policy drift | Kernel policy unchanged since issuance |

---

## Malformed Receipt Handling

### Failure Categories

| Category | Trigger | Kernel Action |
|----------|---------|---------------|
| Schema failure | Unknown version, missing field | REJECT |
| State mismatch | `statePrev ≠ expectedState` | REJECT (unauthorizedTransition) |
| Numeric failure | Parse error, overflow | REJECT (schemaInvalid) |
| Trace failure | `traceLinked = false` | REJECT (stateHashLinkFail) |

---

## Test Vectors

### Nominal Vectors

| Vector | Scenario | Expected |
|--------|----------|----------|
| Safe transition | Risk ≤ threshold, defect ≤ limit | ACCEPT |
| Risk rejection | Risk > threshold | REJECT thresholdExceeded |
| Defect rejection | Defect > limit | REJECT defectOutOfBounds |
| Oplax violation | Descent inequality fails | REJECT oplaxViolation |

### Batch/Telescoping Vectors

| Vector | Scenario | Expected |
|--------|----------|----------|
| Single step | stepCount = 1 | ACCEPT |
| Batch telescoping | stepCount > 1 | ACCEPT |
| Step count mismatch | stepCount != actual steps | REJECT schemaInvalid |
