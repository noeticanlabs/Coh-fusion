# Reviewer Guide

**STATUS: canonical**

## Overview

This document provides the recommended reading order for new reviewers of the Coh-Fusion governance architecture.

---

## Reading Order

### Phase 1: Understand the Scope (10 min)

**Start here**: [`README.md`](README.md)

Read to understand:
- What the project is (a governance architecture, not a full control stack)
- What is NOT claimed
- Wedge boundary concept

**Key takeaway**: This is formal governance, not plasma physics

---

### Phase 2: Understand the Architecture (20 min)

**Next**: [`docs/architecture.md`](docs/architecture.md)

Read to understand:
- Layer ownership (kernel, numeric, control, certificate, receipt, tests)
- Decision flow (state → hazard → certificate → affordability → kernel → receipt → replay)
- What each layer owns and does NOT own

**Key takeaway**: Each layer has explicit responsibility

---

### Phase 3: Understand What's Inside (15 min)

**Next**: [`docs/KERNEL_SCOPE.md`](docs/KERNEL_SCOPE.md)

Read to understand:
- What the kernel checks (input integrity, numeric validity, hazard acceptance, affordability, receipt consistency)
- Gate sequence
- Error modes

**Key takeaway**: The kernel verifies decision legality

---

### Phase 4: Understand What's Outside (10 min)

**Next**: [`docs/EXCLUDED_SURFACES.md`](docs/EXCLUDED_SURFACES.md)

Read to understand:
- Plant truth (outside observables)
- Firmware correctness
- Actuator execution
- Secure attestation
- Raw sensor honesty

**Key takeaway**: These are explicitly outside the wedge

---

### Phase 5: Understand Assumptions (10 min)

**Next**: [`docs/ASSUMPTIONS_AND_DEPENDENCIES.md`](docs/ASSUMPTIONS_AND_DEPENDENCIES.md)

Read to understand:
- External assumptions (sensors, calibration, certificates)
- Internal dependencies (control outputs, QFixed, receipts)
- Trust boundaries

**Key takeaway**: Where trust enters vs. where it's verified

---

### Phase 6: Understand Risks (5 min)

**Next**: [`docs/OPEN_RISKS.md`](docs/OPEN_RISKS.md)

Read to understand:
- Technical risks (regime, observable, theorem gaps)
- Product risks (deployment, explainability)
- Accepted vs. mitigated risks

**Key takeaway**: All risks documented and mitigated or accepted

---

### Phase 7: Understand Build Status (10 min)

**Next**: [`docs/build_status.md`](docs/build_status.md)

Read to understand:
- Canonical files (28)
- Draft files (4)
- Excluded files (1)
- Build blockers, if any

**Key takeaway**: Current implementation state

---

### Phase 8: Understand Proof Status (10 min)

**Next**: [`docs/proof_status.md`](docs/proof_status.md)

Read to understand:
- Proved theorems
- Partial theorems (C-4B under hypothesis)
- Assumed facts
- Excluded surfaces

**Key takeaway**: Formal proof coverage

---

### Phase 9: Understand Tests (10 min)

**Next**: [`docs/test_matrix.md`](docs/test_matrix.md)

Read to understand:
- Kernel tests (complete)
- Certificate tests (complete)
- Control tests (expected)
- Regression tests (complete)

**Key takeaway**: Behavioral freeze coverage

---

## Core Files to Review

### Implementation

| File | What to Review |
|------|----------------|
| `src/CohFusion/Runtime/VerifierSemanticsQFixed.lean` | Kernel implementation |
| `src/CohFusion/Numeric/QFixed.lean` | Numeric arithmetic |
| `src/CohFusion/Core/Receipt.lean` | Receipt generation |
| `src/CohFusion/Product/HardwareCertificate.lean` | Certificate validation |

### Theorems

| File | What to Review |
|------|----------------|
| `src/CohFusion/Control/Theorems/C4B_DissipativeDescent.lean` | C-4B theorem (partial) |
| `src/CohFusion/Geometry/Theorems/C2C_Transversality.lean` | C-2C theorem (proved) |

### Tests

| File | What to Review |
|------|----------------|
| `tests/kernel/kernel_basic.lean` | Kernel tests |
| `tests/certificates/validation_basic.lean` | Certificate tests |

---

## Key Questions to Answer

As a reviewer, verify:

1. **Correctness**: Does the kernel implement the documented contract?
2. **Completeness**: Are all gates implemented in sequence?
3. **Boundary**: Is the internal/external boundary clear?
4. **Assumptions**: Are all external assumptions documented?
5. **Risks**: Are all known risks documented with mitigations?

---

## What NOT to Verify

The reviewer should NOT attempt to verify:

- Sensor accuracy (assumed, outside wedge)
- Firmware correctness (external, outside wedge)
- PDE dynamics (excluded, outside wedge)
- Hardware attestation (external, outside wedge)

---

## Quick Reference

| Document | Purpose |
|----------|---------|
| `README.md` | Project scope |
| `docs/architecture.md` | Layer ownership |
| `docs/KERNEL_SCOPE.md` | Kernel checks |
| `docs/EXCLUDED_SURFACES.md` | What's outside |
| `docs/ASSUMPTIONS_AND_DEPENDENCIES.md` | Trust model |
| `docs/OPEN_RISKS.md` | Known risks |
| `docs/build_status.md` | Implementation state |
| `docs/proof_status.md` | Theorem status |
| `docs/test_matrix.md` | Test coverage |

---

## Review Start Point

For a **quick technical review**:

1. `README.md` → Understand scope
2. `docs/architecture.md` → Understand flow
3. `src/CohFusion/Runtime/VerifierSemanticsQFixed.lean` → Verify kernel implementation

For a **complete architecture review**:

1. Follow all 9 phases above
2. Review core implementation files
3. Review theorem files
4. Review test files