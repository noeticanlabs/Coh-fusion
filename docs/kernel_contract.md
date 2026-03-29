# Kernel Contract

## Purpose

This document defines the **canonical legal transition** for the Coh-Fusion verifier kernel.
It is the single source of truth for what constitutes a legal transition.

---

## Legal Transition Definition

### Inputs

A transition evaluation consumes:

| Input | Type | Description |
|-------|------|-------------|
| `prevState` | `State6 QFixed` | Previous observable state |
| `nextState` | `State6 QFixed` | Next observable state |
| `receipt` | `MicroReceipt QFixed` | Receipt declaring spend/defect |
| `params` | `ParamsFus QFixed` | Geometry parameters (VDE + Tearing) |
| `threshold` | `QFixed` | Maximum acceptable risk value |
| `defectLimit` | `QFixed` | Maximum acceptable defect |
| `gamma` | `QFixed` | Oplax dissipation factor (0 ≤ γ ≤ 1) |

### Outputs

A transition evaluation produces:

| Output | Type | Description |
|--------|------|-------------|
| `decision` | `Decision` | `accept` or `reject` with code |
| `margins` | (implicit) | Computed from VgeomFus values |

### Meaning

A transition is **legal** if and only if **all** of the following predicates succeed:

1. **State Link**: `receipt.statePrev = prevState`
2. **Threshold Gate**: `VgeomFus(params, toStateFus(nextState)) ≤ threshold`
3. **Defect Gate**: `receipt.defectDeclared ≤ defectLimit`
4. **Oplax Gate**: `VgeomFus(params, toStateFus(nextState)) ≤ VgeomFus(params, toStateFus(prevState)) - (1-γ) * receipt.spendAuth + receipt.defectDeclared`

---

## Boundary Policy

### Threshold Semantics (Rule: Open Safe Set)

- **Rejection condition**: `VgeomFus(params, toStateFus(nextState)) > threshold`
- **Acceptance condition**: `VgeomFus(params, toStateFus(nextState)) ≤ threshold`
- **Rationale**: The safe set is **open** — equality at the threshold is accepted

### Defect Semantics (Rule: Open Safe Set)

- **Rejection condition**: `receipt.defectDeclared > defectLimit`
- **Acceptance condition**: `receipt.defectDeclared ≤ defectLimit`
- **Rationale**: The defect limit defines an open safe region

### Spend/Affordability Semantics

- **Affordability check**: Performed via the **Oplax Gate**
- **Logic**: `defect ≤ (1-γ) * spend` is required for strict descent
- **Note**: No separate "budget" parameter — spend is declared in the receipt

### Composite Margin Semantics

- **VDE margin**: `p.Theta_V - VgeomVDE(p.vde, state)`
- **Tearing margin**: `p.Theta_T - VgeomTear(p.tear, state)`
- **Composite**: Conjunction — both must satisfy threshold gate
- **Ordering**: VDE checked first, then Tearing, then oplax

---

## Reject-Code Policy

### Reject Codes and Meanings

| Code | Meaning | Trigger |
|------|---------|---------|
| `unauthorizedTransition` | State linkage failure | `receipt.statePrev ≠ prevState` |
| `thresholdExceeded` | Risk exceeded | `VgeomFus > threshold` |
| `defectOutOfBounds` | Defect exceeded | `defectDeclared > defectLimit` |
| `oplaxViolation` | Dissipative inequality violated | Oplax gate fails |
| `schemaInvalid` | Malformed input | (reserved) |
| `chainDigestMismatch` | Chain integrity failure | (reserved) |
| `unaffordableBurn` | Authority insufficient | (legacy, use `oplaxViolation`) |
| `unauthorizedTransition` | Certificate mismatch | (reserved) |

### Failure Ordering

When multiple failures occur, they are checked in this order:

1. State Link (unauthorizedTransition)
2. Threshold (thresholdExceeded)
3. Defect (defectOutOfBounds)
4. Oplax (oplaxViolation)

The first failing gate determines the reject code.

---

## Kernel Ownership Map

| Module | Ownership |
|--------|-----------|
| `Runtime/VerifierKernel.lean` | **Kernel** — owns final accept/reject decisions |
| `Runtime/VerifierSemanticsQFixed.lean` | **Implementation** — concrete QFixed instantiation |
| `Product/CommercialWedge.lean` | **Wrapper** — calls kernel |
| `Control/BurnPolicyDemo.lean` | **Adapter** — input transformation only |
| `Runtime/Bridge.lean` | **Wrapper** — trace verification, calls kernel |

### Routing Rule

All canonical decision paths MUST route through:

```
Input → Adapter → Kernel → Decision
```

No canonical module may bypass the kernel for final legality decisions.

---

## Current State

### Existing Verifier Kernels

| File | Status | Notes |
|------|--------|-------|
| `Runtime/VerifierSemantics.lean` | generic template | Uses `≥` semantics |
| `Runtime/VerifierSemanticsQFixed.lean` | **canonical** | Uses `>` semantics (matches this contract) |
| `Control/BurnPolicyDemo.lean` | adapter-only | Must be refactored to call kernel |

### Action Required

- `BurnPolicyDemo.verifyIgnition_v3` must be refactored to call `verifyRV_QFixed`
- The generic `verifyRV` should become a thin wrapper or be marked as draft

---

## Notes

- The kernel operates over **QFixed** (fixed-point arithmetic) for deterministic runtime
- Theorem layer operates over **ℚ** (rationals) as "rational shadow"
- The bridge between theorem and runtime is intentionally narrow

---

*Last updated: 2026-03-29*
