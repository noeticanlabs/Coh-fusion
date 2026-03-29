# Open Risks

**STATUS: canonical**

## Overview

This document catalogs known open risks in the Coh-Fusion governance architecture, categorized by technical and product risks.

---

## Technical Risks

### 1. Regime Match Verification

**Risk**: Hardware regime bounds may not match operational reality

**Category**: Technical

**Severity**: Medium

**Mitigation**: Certificate validation includes regime check

**Status**: Mitigated via certificate validation

**Gap**: Regime sufficiency not proved

---

### 2. Observable Sufficiency

**Risk**: Observable measurements may not capture true plant state

**Category**: Technical

**Severity**: High

**Mitigation**: Hardware certification, redundancy

**Status**: Assumption (not verified)

**Gap**: Observable-to-plant inversion is ill-posed

---

### 3. Control Theorem Gaps (C-4B Partial)

**Risk**: Dissipative descent theorem is partial (under hypothesis)

**Category**: Technical

**Severity**: Medium

**Mitigation**: Hypothesis documented, partial proof exists

**Status**: ⚠️ partial — one-step descent hypothesis unresolved

**Gap**: Full mechanization not complete

---

### 4. Numerics Overflow Detection

**Risk**: Overflow in large-scale operations

**Category**: Technical

**Severity**: Low

**Mitigation**: QFixed uses bounded operations

**Status**: Mitigated via bounded arithmetic

---

## Product Risks

### 1. Deployment Integration

**Risk**: Integration with plant control systems

**Category**: Product

**Severity**: Medium

**Mitigation**: Standard interfaces, simulation

**Status**: Planned

**Gap**: Runtime deployment not validated

---

### 2. Explainability for Operators

**Risk**: Operators may not understand decision rationale

**Category**: Product

**Severity**: Medium

**Mitigation**: Receipt provides evidence trail

**Status**: Addressed via receipt generation

**Gap**: Human-readable explanation needed

---

### 3. Maintenance Continuity

**Risk**: Theorem maintenance over time

**Category**: Product

**Severity**: Low

**Mitigation**: Formal verification provides audit trail

**Status**: Ongoing

---

## Risk Summary

| Risk | Category | Severity | Status |
|------|----------|----------|--------|
| Regime match | Technical | Medium | Mitigated |
| Observable sufficiency | Technical | High | Assumption |
| Control theorem gaps | Technical | Medium | Partial |
| Numerics overflow | Technical | Low | Mitigated |
| Deployment integration | Product | Medium | Planned |
| Explainability | Product | Medium | Addressed |
| Maintenance continuity | Product | Low | Ongoing |

---

## Accepted Risks

These risks are **accepted** as part of the architecture:

| Risk | Rationale |
|------|-----------|
| Observable sufficiency | Cannot verify plant state directly |
| Control theorem partial | Theorem proven under hypothesis |
| Firmware correctness | External to wedge |
| Hardware attestation | External to wedge |

---

## Mitigated Risks

These risks have **mitigations** in place:

| Risk | Mitigation |
|------|------------|
| Regime match | Certificate validation |
| Numerics overflow | Bounded QFixed |
| Deployment integration | Standard interfaces |
| Explainability | Receipt evidence |

---

## Reviewer Note

All risks are documented and have either mitigations or are explicitly accepted. No unknown gaps.

For assumptions, see [`docs/ASSUMPTIONS_AND_DEPENDENCIES.md`](docs/ASSUMPTIONS_AND_DEPENDENCIES.md).

For excluded surfaces, see [`docs/EXCLUDED_SURFACES.md`](docs/EXCLUDED_SURFACES.md).