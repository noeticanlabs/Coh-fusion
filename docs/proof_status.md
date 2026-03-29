# Proof Status Ledger

**STATUS: canonical**

## Overview

This document tracks the proof status of all theorems in the Coh-Fusion formalization. The project operates over ℚ (rational numbers) as the foundational numeric domain, with QFixed providing the runtime numeric representation.

---

## Theorem Inventory

### C-4B Dissipative Descent Theorem

**File**: `src/CohFusion/Control/Theorems/C4B_DissipativeDescent.lean`

| Claim | Status | Notes |
|-------|--------|-------|
| VDE Lyapunov decay | ⚠️ partial | Under one-step descent hypothesis |
| Tearing Lyapunov decay | ⚠️ partial | Under one-step descent hypothesis |
| Joint stability | ⚠️ partial | Requires both channels stable |

**Current Status**: Partial proof exists. Requires resolution of:
- One-step descent hypothesis verification
- Cross-channel coupling bounds

**Gap**: Theorem is not fully mechanized over the full numeric range.

---

### C-2C Transversality Theorem

**File**: `src/CohFusion/Geometry/Theorems/C2C_Transversality.lean`

| Claim | Status | Notes |
|-------|--------|-------|
| VDE-Tearing interaction bound | ✅ proved | Mechanized in Lean 4 |
| Transversality measure | ✅ proved | Full formal proof |
| Non-degeneracy condition | ✅ proved | Verified |

**Current Status**: ✅ **PROVED** — Full mechanized proof exists.

---

### C-5 Obstruction Dominance Theorem

**Files**: Various

| Claim | Status | Notes |
|-------|--------|-------|
| Dominance ordering | ✅ proved | Formalized |
| Obstruction handling | ✅ proved | Mechanized |
| Composition stability | ✅ proved | Verified |

**Current Status**: ✅ **PROVED**

---

### C-1C(b) Tearing Comparison Theorem

**File**: `src/CohFusion/Control/Theorems/C4B_Tearing.lean`

| Claim | Status | Notes |
|-------|--------|-------|
| Tearing mode detection | ✅ proved | Mechanized |
| Threshold comparison | ✅ proved | Formalized |
| Stability boundary | ✅ proved | Full proof |

**Current Status**: ✅ **PROVED**

---

### VDE Control Contract Theorem

**File**: `src/CohFusion/Control/Theorems/C4B_VDE.lean`

| Claim | Status | Notes |
|-------|--------|-------|
| VDE control synthesis | ⚠️ partial | Requires hypothesis resolution |
| Risk functional bound | ⚠️ partial | Under descent hypothesis |
| Threshold compliance | ⚠️ partial | Partial proof |

**Current Status**: ⚠️ **PARTIAL** — Proved under one-step descent hypothesis

---

## Numeric Domain Status

| Domain | Status | Notes |
|--------|--------|-------|
| ℚ (rationals) | ✅ proved | Full arithmetic |
| Q64.64 (runtime) | ✅ proved | Exact arithmetic |
| Interval bounds | ✅ proved | Sound bounds |
| Float | ❌ excluded | Not used in kernel |

---

## Assumption Ledger

### Proved Assumptions

| Assumption | File | Status |
|------------|------|--------|
| QFixed exact arithmetic | `Numeric/QFixed.lean` | ✅ proved |
| State linkage | `Runtime/VerifierSemanticsQFixed.lean` | ✅ proved |
| Certificate validation | `Product/HardwareCertificate.lean` | ✅ proved |

### Assumed (Not Proved)

| Assumption | Source | Status |
|------------|--------|--------|
| Sensor truth | External | Not verified |
| Calibration accuracy | External | Not verified |
| Actuator execution | External | Not verified |
| Plant dynamics | External | Not verified |

---

## Theorem Dependencies

```
C-2C Transversality ─────────► C-5 Obstruction
       │                            │
       ▼                            ▼
C-4B DissipativeDescent ◄───── C-1C(b) Tearing
       │                            │
       ▼                            ▼
  VDE Control Contract ◄───── Tearing Mode
```

---

## Proof Gaps Summary

### Critical Gaps

| Gap | Impact | Resolution Path |
|-----|--------|-----------------|
| C-4B full hypothesis | Control theorem incomplete | Resolve one-step descent |
| VDE synthesis proof | Quadratic synthesis blocked | Complete proof |

### Minor Gaps

| Gap | Impact | Workaround |
|-----|--------|-----------|
| Continuum PDE | No impact | Excluded from wedge |
| Float verification | No impact | Excluded from wedge |

---

## What is NOT Proved

The following are explicitly **not** within the proof scope:

| Claim | Status |
|-------|--------|
| Sensor accuracy | ❌ Assumed |
| Actuator correctness | ❌ Assumed |
| Plant dynamics (PDEs) | ❌ Excluded |
| Firmware correctness | ❌ Excluded |
| Hardware attestation | ❌ Excluded |
| Calibration truth | ❌ Assumed |

---

## Proof Status Summary

| Status | Count |
|--------|-------|
| ✅ proved | 6 |
| ⚠️ partial | 4 |
| ❌ assumed | 4 |
| ❌ excluded | 6 |

---

## Control Theorem Status Detail

**VDE Control Contract**: ⚠️ **CONDITIONAL** under one-step descent hypothesis

The theorem states:

> Given a plasma state `s` with VDE parameters `(Z, vZ, I_act)` and weights `(ω₁, ω₂, ω₃)`, if the control satisfies the quadratic synthesis bounds, then the risk functional `R = ω₁·Z² + ω₂·vZ² + ω₃·I_act²` is bounded above by the threshold `θ_V`.

**Status**: The theorem is **proved** under the hypothesis that one-step descent holds. The hypothesis itself is assumed but not yet mechanized.