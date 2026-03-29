# Architecture Document

**STATUS: canonical**

## Overview

This document defines the canonical layer ownership and decision flow for the Coh-Fusion governance architecture. Each layer has explicit ownership over a specific aspect of the verification pipeline.

---

## Layer Ownership Model

Each layer in the typed tower owns a distinct responsibility:

### Layer Summary

| Layer | Owner | Guarantees | Files |
|-------|-------|-------------|-------|
| **kernel** | decision legality | Accept/reject decisions are legal under policy | `Runtime/VerifierSemantics*.lean` |
| **numeric** | arithmetic determinism | Fixed-point arithmetic is exact, no float | `Numeric/QFixed.lean`, `Numeric/BoundsAxioms.lean` |
| **control** | hazard outputs | Risk functional computation is correct | `Control/VDE_Quadratic.lean`, `Control/Tearing_Quadratic.lean` |
| **certificate** | authority gating | Only valid certificates enable decisions | `Product/HardwareCertificate.lean` |
| **receipt** | evidence/replay | Decisions are traceable and auditable | `Core/Receipt.lean`, `Runtime/HashBoundedReceipt.lean` |
| **tests** | behavioral freeze | Known-good behavior is pinned | `tests/kernel/`, `tests/certificates/` |

---

## Layer Details

### Kernel Layer

**Owner**: `Runtime/VerifierSemanticsQFixed.lean`

**Responsibility**: Decision verification

**Guarantees**:
- Input integrity (state linkage verified)
- Numeric validity (QFixed arithmetic)
- Hazard acceptance (threshold checks)
- Affordability (budget enforcement)
- Receipt consistency (replay verification)

**What it checks**:
```
1. State linkage: receipt.statePrev = prevState
2. Threshold: VgeomFus(params, nextState) > threshold → REJECT
3. Defect: defectDeclared > defectLimit → REJECT
4. Affordability: oplax condition → REJECT
```

For full kernel scope, see [`docs/KERNEL_SCOPE.md`](docs/KERNEL_SCOPE.md).

---

### Numeric Layer

**Owner**: `Numeric/QFixed.lean`

**Responsibility**: Arithmetic determinism

**Guarantees**:
- Exact arithmetic (no floating-point)
- Deterministic comparison (open safe set: `>` rejects, `≤` accepts)
- Bounded operations (no overflow in kernel)
- Exact decimal parsing

**What it provides**:
- `QFixed` type (Q64.64 fixed-point)
- `fromDecimalString` (exact conversion)
- `add`, `mul`, `div` (exact operations)
- Interval bounds (`Interval.lean`)

---

### Control Layer

**Owner**: `Control/VDE_Quadratic.lean`, `Control/Tearing_Quadratic.lean`

**Responsibility**: Hazard evidence

**Guarantees**:
- Risk functional computation
- Threshold comparison
- Composition logic (conjunctive: both channels safe)

**Evidence provided**:
```
VDE:  risk = ω1·Z² + ω2·vZ² + ω3·I_act²
Tearing: risk = ν1·W² + ν2·vW² + ν3·I_cd²
```

**Composition**: Both must be safe (conjunctive)

For control contract, see [`docs/control_contract.md`](docs/control_contract.md).

---

### Certificate Layer

**Owner**: `Product/HardwareCertificate.lean`

**Responsibility**: Authority gating

**Guarantees**:
- Certificate validity (not expired)
- Signature format (valid structure)
- Root of trust (chain validation)
- Regime matching (hardware bounds)

**Validation gates**:
```
1. Expiry: not expired → continue, else CERT_EXPIRED
2. Signature format: valid → continue, else INVALID_SIGNATURE
3. Root of trust: present → continue, else MISSING_ROOT
4. Regime: matches bounds → continue, else REGIME_MISMATCH
```

For certificate contract, see [`docs/certificate_contract.md`](docs/certificate_contract.md).

---

### Receipt Layer

**Owner**: `Core/Receipt.lean`

**Responsibility**: Evidence and replay

**Guarantees**:
- State binding (prev → next)
- Evidence capture (inputs, outputs, defect)
- Replay capability (decision reconstruction)

**Receipt structure**:
```lean
MicroReceipt := {
  statePrev : State,
  stateNext : State,
  spend : QFixed,
  defect : QFixed,
  certificate : Certificate,
  decision : Decision
}
```

**Replay**: Recompute decision from receipt. Must match.

For receipt contract, see [`docs/receipt_contract.md`](docs/receipt_contract.md).

---

### Tests Layer

**Owner**: `tests/kernel/kernel_basic.lean`, `tests/certificates/validation_basic.lean`

**Responsibility**: Behavioral freeze

**Guarantees**:
- Kernel accept path works
- All reject paths work
- Boundary cases work
- Certificate validation works
- Regression fixes hold

For test matrix, see [`docs/test_matrix.md`](docs/test_matrix.md).

---

## Decision Flow

The canonical flow through layers:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        DECISION FLOW                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   STATE_PREV                                                           │
│       │                                                                │
│       ▼                                                                │
│   ┌─────────┐    ┌─────────────┐    ┌──────────────┐                  │
│   │ CONTROL │───▶│ HAZARD      │───▶│ EVIDENCE     │                  │
│   │ Layer   │    │ computation │    │ (risk vals)  │                  │
│   └─────────┘    └─────────────┘    └──────────────┘                  │
│                                             │                         │
│                                             ▼                         │
│   ┌──────────────┐    ┌─────────────────┐    ┌──────────┐            │
│   │ CERTIFICATE │───▶│ AUTHORITY       │───▶│ VALIDATE │            │
│   │ Layer       │    │ gating           │    │          │            │
│   └──────────────┘    └─────────────────┘    └──────────┘            │
│                                             │                         │
│                                             ▼                         │
│   ┌────────────────────────────────────────────────────────────────┐  │
│   │                      KERNEL                                       │  │
│   │  ┌─────────────────────────────────────────────────────────────┐ │  │
│   │  │ 1. State linkage    (receipt.statePrev = prevState)       │ │  │
│   │  │ 2. Threshold         (VgeomFus > threshold → REJECT)       │ │  │
│   │  │ 3. Defect            (defect > limit → REJECT)             │ │  │
│   │  │ 4. Affordability     (oplax condition → REJECT)            │ │  │
│   │  └──────────────────���──────────────────────────────────────────┘ │  │
│   └────────────────────────────────────────────────────────────────┘  │
│                                             │                         │
│                                             ▼                         │
│   ┌──────────┐    ┌─────────────┐    ┌─────────────┐                  │
│   │ RECEIPT  │◀───│ EMIT        │◀───│ DECISION   │                  │
│   │ Layer    │    │             │    │ (accept/rej)│                  │
│   └──────────┘    └─────────────┘    └─────────────┘                  │
│                                             │                         │
│                                             ▼                         │
│   ┌─────────────────────────────────────────────────────────────────┐ │
│   │                      REPLAY                                       │ │
│   │  Recompute decision from receipt. Must match.                  │ │
│   └─────────────────────────────────────────────────────────────────┘ │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Flow Description

### State → Hazard → Certificate → Affordability → Kernel → Receipt → Replay

1. **State**: Current plasma state (VDE params, Tearing params, etc.)

2. **Hazard**: Control layer computes risk functional:
   - VDE risk = ω₁·Z² + ω₂·vZ² + ω₃·I_act²
   - Tearing risk = ν₁·W² + ν₂·vW² + ν₃·I_cd²

3. **Certificate**: Hardware certificate validated as authority gate:
   - Not expired
   - Valid signature
   - Root of trust present
   - Regime matches bounds

4. **Affordability**: Budget check (oplax condition):
   - `V(next) > V(prev) - (1-γ)·spend + defect` → REJECT

5. **Kernel**: Final verification:
   - State linkage
   - Threshold comparison
   - Defect bounds
   - All conditions enforced

6. **Receipt**: Evidence generated:
   - State binding
   - Decision capture
   - Full trace for audit

7. **Replay**: Verification through recomputation:
   - Reconstruct from receipt
   - Decision must match
   - Audit-ready

---

## Layer Dependencies

```
numeric ──────► kernel ──────► receipt
    │                │
    ▼                ▼
control ◄──────── certificate
    │
    ▼
geometry
```

**Dependency rules**:
- Numeric foundational (no deps) → kernel → receipt
- Control provides evidence → kernel consumes
- Certificate gates authority → kernel validates
- Geometry provides state → control computes

---

## What Each Layer Does NOT Own

| Layer | Does NOT Own |
|-------|--------------|
| kernel | Sensor truth, actuator execution, plant dynamics |
| numeric | Physical units, calibration, measurement |
| control | Final decision, hardware bounds, actuator commands |
| certificate | Firmware correctness, physical hardware, attestation |
| receipt | Sensor accuracy, plant state truth, execution traces |
| tests | Proof verification, theorem completeness |

For what's excluded, see [`docs/EXCLUDED_SURFACES.md`](docs/EXCLUDED_SURFACES.md).

---

## Buildable Subset

The minimal wedge path:

```
numeric → core → geometry → runtime → product
         ↓                         ↓
       control ◄──────────────── certificate
```

For file-level status, see [`docs/build_status.md`](docs/build_status.md).