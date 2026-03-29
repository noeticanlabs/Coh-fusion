# Excluded Surfaces

**STATUS: canonical**

## Overview

This document explicitly defines what is outside the wedge boundary. These surfaces are explicitly excluded from the formalization scope.

---

## What is Excluded

### 1. Plant Truth (Outside Observables)

**Excluded**: The true physical state of the plasma

**Why excluded**:
- Direct measurement impossible
- Requires inverse problem solving
- PDE inversion is ill-posed

**The kernel assumes**: Observables are truth-proximate

**Risk**: Observable sufficiency cannot be formally verified

---

### 2. Firmware Correctness

**Excluded**: Actuator firmware execution

**Why excluded**:
- Third-party firmware
- Binary distribution
- No source access

**The kernel assumes**: Firmware executes as commanded

**Risk**: Execution divergence not detectable

---

### 3. Actuator Execution

**Excluded**: Physical actuator dynamics

**Why excluded**:
- Hardware layer
- Response time variation
- Mechanical dynamics

**The kernel assumes**: Commands execute within bounds

**Risk**: Timing/integrity not verified

---

### 4. Secure Attestation

**Excluded**: Hardware root of trust

**Why excluded**:
- External certification
- TPM interface outside wedge
- Chain of trust verification

**The kernel assumes**: Root of trust is valid

---

### 5. Raw Sensor Honesty

**Excluded**: Sensor accuracy and calibration

**Why excluded**:
- Hardware calibration
- Drift over time
- Physical limits

**The kernel assumes**: Sensors are accurate within bounds

**Risk**: Systematic bias not detectable

---

## Excluded Surface Summary

| Surface | Assumption | Risk |
|---------|-----------|------|
| Plant truth | Observables are truth-proximate | Observable sufficiency |
| Firmware correctness | Code runs as specified | Execution divergence |
| Actuator execution | Commands execute | Timing/integrity |
| Secure attestation | Root of trust valid | Chain of trust |
| Raw sensor honesty | Sensors are accurate | Systematic bias |

---

## Implication on Assumptions

For each excluded surface, the kernel makes assumptions:

1. **Observables truthful**: `Observables.lean` interface assumes sensor fidelity

2. **Calibration metadata**: External calibration assumed accurate

3. **Certificate artifacts**: Hardware certificates assumed valid

4. **Actuator bounds**: Firmware assumes bounded response

---

## What This Means

### The Kernel Does NOT Claim To:

- **Verify plant state** — Assumes observables
- **Verify firmware** — Assumes firmware correctness
- **Verify actuator execution** — Assumes command execution
- **Verify attestation** — Assumes chain of trust
- **Verify sensor accuracy** — Assumes sensor honesty

### The Kernel DOES Claim To:

- **Verify decision legality** — Accept/reject is legal
- **Verify certificate validity** — Format, expiry, regime
- **Verify arithmetic** — Deterministic QFixed
- **Verify replay** — Receipt traceable

---

## Boundary Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      WEDGE BOUNDARY                        │
├─────────────────────────┬───────────────────────────────────┤
│      INSIDE              │           OUTSIDE                  │
├─────────────────────────┼───────────────────────────────────┤
│  Decision logic         │  Plant dynamics (PDEs)            │
│  Numeric arithmetic   │  Sensor accuracy                  │
│  Certificate validation │  Firmware execution              │
│  Receipt generation  │  Actuator dynamics               │
│  Replay verification │  Hardware attestation           │
│                       │  Calibration metadata           │
└─────────────────────────┴───────────────────────────────────┘
```

---

## Gap Documentation

### Observable Sufficiency

**Gap**: `docs/C_gap_ledger.md`

The gap between observable measurements and true plant state cannot be formally bridged. This is documented as an assumption.

### Firmware Correctness

**Gap**: Hardware interface

Firmware correctness is assumed and delegated to hardware certification processes.

### Actuator Execution

**Gap**: Command interface

Actuator execution bounds are assumed from hardware specifications.

---

## Reviewer Note

This is **not** a limitation of the formalization — this is the deliberate boundary of the governance architecture.

For assumptions and dependencies, see [`docs/ASSUMPTIONS_AND_DEPENDENCIES.md`](docs/ASSUMPTIONS_AND_DEPENDENCIES.md).