# Kernel Scope

**STATUS: canonical**

## Overview

This document defines what the kernel checks and what it explicitly does NOT check. The kernel is the final verification layer in the decision pipeline.

---

## What the Kernel Checks

### 1. Input Integrity

**Check**: State linkage verification

```
verifyStateLink(receipt, prevState) =
  receipt.statePrev == prevState
```

**Failure mode**: `UNAUTHORIZED_TRANSITION`

**Rationale**: Ensures the receipt corresponds to the claimed previous state.

---

### 2. Numeric Validity

**Check**: Fixed-point arithmetic correctness

- No floating-point in kernel path
- Exact integer comparison
- Open safe set: `>` rejects, `≤` accepts
- Bounded operations (no overflow)

**Implementation**: `QFixed` type (Q64.64)

---

### 3. Hazard Acceptance

**Check**: Threshold comparison

```
verifyThreshold(params, nextState) =
  VgeomFus(params, nextState) <= threshold
```

**Failure mode**: `THRESHOLD_EXCEEDED`

**Rationale**: Ensures geometric functional is within safe bounds.

**Components checked**:
- VDE functional: `ω₁·Z² + ω₂·vZ² + ω₃·I_act²`
- Tearing functional: `ν₁·W² + ν₂·vW² + ν₃·I_cd²`

---

### 4. Defect Bounds

**Check**: Defect declaration within limits

```
verifyDefect(defect, limit) =
  defect <= limit
```

**Failure mode**: `DEFECT_OUT_OF_BOUNDS`

**Rationale**: Ensures declared defect is within acceptable bounds.

---

### 5. Affordability

**Check**: Budget condition (oplax)

```
verifyAffordability(prevState, nextState, spend, defect) =
  V(nextState) <= V(prevState) - (1 - γ) * spend + defect
```

**Failure mode**: `AFFORDABILITY_VIOLATION`

**Rationale**: Ensures the transition is affordable within budget.

---

### 6. Receipt Consistency

**Check**: Replay verification

```
verifyReplay(receipt) =
  recomputeDecision(receipt) == receipt.decision
```

**Failure mode**: `REPLAY_MISMATCH`

**Rationale**: Ensures the decision can be reconstructed from the receipt.

---

## Kernel Gate Sequence

All checks run in fixed order, first failure wins:

```
Gate 1: State linkage     → UNAUTHORIZED_TRANSITION
Gate 2: Threshold        → THRESHOLD_EXCEEDED  
Gate 3: Defect bounds     → DEFECT_OUT_OF_BOUNDS
Gate 4: Affordability    → AFFORDABILITY_VIOLATION
Gate 5: Receipt replay   → REPLAY_MISMATCH
```

---

## What the Kernel Does NOT Check

### External Assumptions (Not Verified)

| Check | Why Not Checked |
|-------|----------------|
| **Sensor truth** | Hardware assumption |
| **Calibration accuracy** | External metadata |
| **Actuator execution** | Firmware layer |
| **Plant dynamics** | PDEs outside wedge |
| **Hardware attestation** | External process |

### Internal Assumptions (Proved Elsewhere)

| Check | Proof Location |
|-------|---------------|
| **Control theorem** | `Control/Theorems/*.lean` |
| **Numeric determinism** | `Numeric/QFixed.lean` |
| **Certificate validity** | `Product/HardwareCertificate.lean` |

---

## Kernel Contract

### Preconditions

| Condition | Source |
|-----------|--------|
| Valid receipt | Certificate layer |
| Valid certificate | Certificate validation |
| Hazard evidence | Control layer |
| State parameters | Input |
| Budget parameters | Policy |

### Postconditions

| Condition | Source |
|-----------|--------|
| Decision.emit in {Accept, Reject} | Kernel |
| Receipt generated | Kernel |
| Replay possible | Kernel |

---

## Numeric Domain

The kernel operates over **QFixed** (Q64.64 fixed-point):

| Property | Value |
|----------|-------|
| Format | Fixed-point (2^64 scale) |
| Internal | Lean `Int` (arbitrary precision) |
| Comparison | Exact integer comparison |
| Float | **Banned** from kernel |
| Parse | `fromDecimalString` — exact |

---

## Error Modes

| Mode | Code | Description |
|------|------|-------------|
| `UNAUTHORIZED_TRANSITION` | 0x01 | State linkage failed |
| `THRESHOLD_EXCEEDED` | 0x02 | Geometric threshold exceeded |
| `DEFECT_OUT_OF_BOUNDS` | 0x03 | Defect exceeds limit |
| `AFFORDABILITY_VIOLATION` | 0x04 | Budget violated |
| `REPLAY_MISMATCH` | 0x05 | Receipt replay failed |
| `CERT_EXPIRED` | 0x10 | Certificate expired |
| `INVALID_SIGNATURE` | 0x11 | Invalid signature format |
| `MISSING_ROOT` | 0x12 | Root of trust missing |
| `REGIME_MISMATCH` | 0x13 | Regime mismatch |

---

## Boundary Semantics

The kernel uses **open safe set** semantics:

| Comparison | Semantic |
|------------|----------|
| `>` | **REJECT** — unsafe |
| `≤` | **ACCEPT** — safe |
| `==` | **ACCEPT** — on boundary |

**Convention**: Margin > 0 = safe slack, Margin = 0 = boundary, Margin < 0 = breach

For kernel flow, see [`docs/kernel_flow.md`](docs/kernel_flow.md).