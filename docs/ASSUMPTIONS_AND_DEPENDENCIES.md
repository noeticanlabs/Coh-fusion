# Assumptions and Dependencies

**STATUS: canonical**

## Overview

This document catalogs all external assumptions and internal dependencies for the Coh-Fusion governance architecture.

---

## External Assumptions

Assumptions that come **from outside the wedge**:

### 1. Observable Truth

**Assumption**: Sensor measurements reflect actual plant state

**Source**: Hardware layer

**Trust model**: Assumed accurate within sensor specifications

**Risk if violated**: Observable sufficiency gap

**Mitigation**: Hardware certification, redundancy, diagnostics

---

### 2. Calibration Metadata

**Assumption**: Calibration data is accurate

**Source**: External calibration process

**Trust model**: Assumed valid and up-to-date

**Risk if violated**: Systematic bias in measurements

**Mitigation**: Regular recalibration, drift monitoring

---

### 3. Certificate Artifacts

**Assumption**: Hardware certificates are valid

**Source**: External certification authority

**Trust model**: Assumed genuine and unexpired

**Risk if violated**: Unauthorized control access

**Mitigation**: Certificate validation chain, root of trust

---

### 4. Regime Definitions

**Assumption**: Hardware bounds match physical limits

**Source**: Hardware specifications

**Trust model**: Assumed accurate

**Risk if violated**: Out-of-regime operation

**Mitigation**: Regime validation in certificate

---

## Internal Dependencies

Dependencies that are **proved within the wedge**:

### 1. Control Outputs Respect Contract

**Dependency**: Control layer provides valid hazard evidence

**Proof**: Theorem proves computation correctness

**Status**: ⚠️ partial — under one-step descent hypothesis

**Location**: `Control/Theorems/*.lean`

---

### 2. QFixed Parsing Canonical

**Dependency**: Decimal parsing is exact

**Proof**: Exact integer arithmetic proof

**Status**: ✅ proved

**Location**: `Numeric/QFixed.lean`

---

### 3. Receipt Linkage Valid

**Dependency**: Receipts properly bind state transitions

**Proof**: Receipt structure verification

**Status**: ✅ proved

**Location**: `Core/Receipt.lean`, `Runtime/VerifierSemanticsQFixed.lean`

---

### 4. Certificate Validation Complete

**Dependency**: All invalid certificates rejected

**Proof**: Validation pipeline verification

**Status**: ✅ proved

**Location**: `Product/HardwareCertificate.lean`

---

## Assumption Ledger

| Assumption | Type | Source | Status |
|------------|------|--------|--------|
| Sensors truthful | External | Hardware | Assumed |
| Calibration accurate | External | Process | Assumed |
| Certificate valid | External | Authority | Assumed |
| Regime bounds correct | External | Hardware | Assumed |
| Control computation correct | Internal | Math | ⚠️ partial |
| Numeric exact | Internal | Math | ✅ proved |
| Receipt valid | Internal | Code | ✅ proved |

---

## Dependency Graph

```
EXTERNAL                          INTERNAL
─────────                         ────────
Sensors ──────┐                   Numeric ───► Kernel
              │                       │           │
Calibration ─┼──► Kernel ◄── Control            │
              │                   │              ▼
Certificate ─┘                   Receipt ◄──────┘
```

---

## Trust Boundaries

### Where Trust Enters

1. **Hardware certificate** — Root of trust
2. **Sensor readings** — Hardware layer
3. **Calibration** — External process
4. **Actuator bounds** — Hardware spec

### Where Trust is Verified

1. **Certificate validation** — Internal (proof available)
2. **Numeric arithmetic** — Internal (proof available)
3. **State linkage** — Internal (proof available)
4. **Decision replay** — Internal (proof available)

### Where Trust is Assumed

1. **Observable accuracy** — External (not verified)
2. **Firmware execution** — External (not verified)
3. **Actuator dynamics** — External (not verified)
4. **Hardware attestation** — External (not verified)

---

## Reviewer Note

**External assumptions are not a weakness** — they are the deliberate boundary of the governance architecture. The kernel verifies what's verifiable and explicitly documents what it assumes.

For what's excluded, see [`docs/EXCLUDED_SURFACES.md`](docs/EXCLUDED_SURFACES.md).

For open risks, see [`docs/OPEN_RISKS.md`](docs/OPEN_RISKS.md).