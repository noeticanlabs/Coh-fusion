# Test Matrix

**STATUS: canonical**

## Overview

This document tracks test coverage for the canonical test suite, organized by layer and coverage area.

---

## Coverage Status Matrix

| Layer | Category | Coverage | Tests | Status |
|-------|----------|---------|-------|--------|
| **Kernel** | Accept path | ✅ Complete | 1 | kernel accepts valid transitions |
| **Kernel** | Reject - unauthorizedTransition | ✅ Complete | 1 | rejects when statePrev mismatch |
| **Kernel** | Reject - thresholdExceeded | ✅ Complete | 1 | rejects when V > threshold |
| **Kernel** | Reject - defectOutOfBounds | ✅ Complete | 1 | rejects when defect > limit |
| **Kernel** | Boundary - exact equality | ✅ Complete | 1 | boundary case (≤ accepts) |
| **Numeric** | Parse valid | ✅ Complete | 1 | valid decimal parsing |
| **Numeric** | Parse malformed | ✅ Complete | 1 | malformed input rejection |
| **Numeric** | Equality | ✅ Complete | 1 | exact equality comparison |
| **Numeric** | Overflow handling | ✅ Complete | 1 | bounded ops enforcement |
| **Receipts** | Parse valid | ✅ Complete | 1 | receipt parsing |
| **Receipts** | Linkage | ✅ Complete | 1 | statePrev → stateNext |
| **Receipts** | Replay | ✅ Complete | 1 | decision reconstruction |
| **Control** | VDE safe | ✅ Complete | 1 | safe VDE computation |
| **Control** | VDE boundary | ✅ Complete | 1 | boundary threshold |
| **Control** | Tearing safe | ✅ Complete | 1 | safe tearing computation |
| **Control** | Composition | ✅ Complete | 1 | conjunctive logic |
| **Certificates** | Valid | ✅ Complete | 1 | valid cert acceptance |
| **Certificates** | Expired | ✅ Complete | 1 | expiry rejection |
| **Certificates** | Missing signature | ✅ Complete | 1 | format rejection |
| **Certificates** | Invalid format | ✅ Complete | 1 | format rejection |
| **Certificates** | Missing root | ✅ Complete | 1 | root rejection |
| **Certificates** | Regime mismatch | ✅ Complete | 1 | regime rejection |
| **Vectors** | Accept (A) | ✅ Complete | 1 | golden accept vector |
| **Vectors** | Hazard reject (B) | ✅ Complete | 1 | hazard rejection vector |
| **Vectors** | Authority reject (C) | ✅ Complete | 1 | authority rejection |
| **Vectors** | Affordability reject (D) | ✅ Complete | 1 | affordability rejection |
| **Vectors** | Malformed (E) | ✅ Complete | 1 | malformed input |
| **Regressions** | QFixed parse | ✅ Complete | 1 | parse regression |
| **Regressions** | matchesRegime | ✅ Complete | 1 | regime regression |

---

## Test Files

### Kernel Tests

| File | Coverage | Status |
|------|----------|--------|
| `tests/kernel/kernel_basic.lean` | Accept + 4 reject + boundary | ✅ Complete |

### Numeric Tests

| File | Coverage | Status |
|------|----------|--------|
| `tests/numeric/qfixed_basic.lean` | Parse valid | ✅ Complete |
| `tests/numeric/qfixed_malformed.lean` | Parse malformed | ✅ Complete |
| `tests/numeric/qfixed_equality.lean` | Equality | ✅ Complete |
| `tests/numeric/qfixed_overflow.lean` | Overflow | ✅ Complete |

### Receipt Tests

| File | Coverage | Status |
|------|----------|--------|
| `tests/receipts/receipt_parse.lean` | Parse valid | ✅ Complete |
| `tests/receipts/receipt_linkage.lean` | Linkage | ✅ Complete |
| `tests/receipts/receipt_replay.lean` | Replay | ✅ Complete |

### Control Tests

| File | Coverage | Status |
|------|----------|--------|
| `tests/control/vde_safe.lean` | VDE safe | ✅ Complete |
| `tests/control/vde_boundary.lean` | VDE boundary | ✅ Complete |
| `tests/control/tearing_safe.lean` | Tearing safe | ✅ Complete |
| `tests/control/composition.lean` | Composition | ✅ Complete |

### Certificate Tests

| File | Coverage | Status |
|------|----------|--------|
| `tests/certificates/validation_basic.lean` | Full validation pipeline | ✅ Complete |

### Golden Vectors

| File | Coverage | Status |
|------|----------|--------|
| `tests/vectors/vector_accept.json` | Accept (A) | ✅ Complete |
| `tests/vectors/vector_hazard_reject.json` | Hazard reject (B) | ✅ Complete |
| `tests/vectors/vector_authority_reject.json` | Authority reject (C) | ✅ Complete |
| `tests/vectors/vector_affordability_reject.json` | Affordability reject (D) | ✅ Complete |
| `tests/vectors/vector_malformed.json` | Malformed (E) | ✅ Complete |

### Regression Tests

| File | Coverage | Status |
|------|----------|--------|
| `tests/regressions/regression_qfixed_parse.lean` | QFixed parse | ✅ Complete |
| `tests/regressions/regression_matchesRegime.lean` | matchesRegime | ✅ Complete |

---

## End-to-End Coverage

| Scenario | Vector | Status |
|----------|--------|--------|
| Valid transition + valid cert | A | ✅ Complete |
| Hazard threshold exceeded | B | ✅ Complete |
| Invalid certificate | C | ✅ Complete |
| Affordability violation | D | ✅ Complete |
| Malformed input | E | ✅ Complete |

---

## Regression Coverage

| Regression | Test | Status |
|------------|------|--------|
| QFixed parse edge cases | `regression_qfixed_parse.lean` | ✅ Complete |
| Regime matching edge cases | `regression_matchesRegime.lean` | ✅ Complete |

---

## Status Summary

| Area | Complete | Pending |
|------|----------|---------|
| Kernel tests | 5 | 0 |
| Numeric tests | 4 | 0 |
| Receipt tests | 3 | 0 |
| Control tests | 4 | 0 |
| Certificate tests | 6 | 0 |
| Golden vectors | 5 | 0 |
| Regression tests | 2 | 0 |
| **Total** | **29** | **0** |

---

## Coverage Gaps (None)

All planned tests are complete. There are no pending test coverage areas.

---

## Behavioral Freeze

The test suite freezes the following behavioral invariants:

| Invariant | Tests |
|-----------|-------|
| Kernel accept path works | 1 test |
| All reject paths work | 4 tests |
| Boundary cases work | 1 test |
| Certificate validation works | 6 tests |
| Control computation works | 4 tests |
| Replay verification works | 1 test |

For test contract, see [`docs/test_contract.md`](docs/test_contract.md).