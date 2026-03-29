# Test Contract

## Purpose

This document defines the canonical test suite architecture for the Coh-Fusion verifier. It establishes test organization, coverage requirements, and regression discipline.

---

## Test Organization

### Folder Structure

```
tests/
├── kernel/          # Kernel decision tests
├── numeric/         # QFixed arithmetic tests
├── receipts/        # Receipt/trace tests
├── control/         # VDE/Tearing tests
├── certificates/    # Authority gate tests
├── vectors/         # Golden end-to-end vectors
└── regressions/     # Bug fix regression tests
```

### Canonical vs Experimental

**Canonical tests** define the wedge's current legal behavior. These must:
- Have stable, documented expected outcomes
- Be maintained across repo evolution
- Cover all decision-bearing paths

**Experimental tests** explore future behavior, alternate models, or draft files. These:
- May change without notice
- Live in `tests/experimental/` (if created)
- Are clearly marked as non-canonical

---

## Kernel Decision Tests (`tests/kernel/`)

### Reject Codes

The kernel uses these rejection codes:

| Code | Meaning |
|------|---------|
| `schemaInvalid` | Malformed input schema |
| `chainDigestMismatch` | Digest verification failed |
| `stateHashLinkFail` | State linkage broken |
| `thresholdExceeded` | Safety envelope breached |
| `defectOutOfBounds` | Defect exceeds limit |
| `oplaxViolation` | Dissipative inequality violated |
| `overflow` | Arithmetic overflow |
| `unauthorizedTransition` | State linkage failure |
| `unaffordableBurn` | Insufficient authority |

### Test Requirements

| Category | Tests Required |
|----------|---------------|
| Accept path | Valid inputs, certificate, spend, hazard outputs |
| Reject by class | One test per reject code |
| Boundary | Exact equality at threshold, defectLimit, zero margin |
| Failure order | Multiple failures return canonical order |

---

## Numeric Domain Tests (`tests/numeric/`)

### Test Classes

| Class | Coverage |
|-------|----------|
| Parse | Valid string, malformed, empty, sign errors |
| Equality | Exact threshold, defectLimit, budget |
| Overflow | Add, multiply, conversion |
| Normalization | Canonical zero, equivalent forms |
| Determinism | Repeated parse, compare, replay |

### QFixed Semantics

- Scale: 2^64
- Internal representation: arbitrary-precision Int
- Rejected: Float, Double, scientific notation

---

## Receipt/Trace Tests (`tests/receipts/`)

### Test Classes

| Class | Coverage |
|-------|----------|
| Parse | Valid receipt, bad schema, missing field |
| Linkage | statePrev/stateNext hash matching |
| Trace | Parent linkage, broken chain |
| Replay | Tampered fields detected |
| Consistency | Accept/reject matches recomputation |

---

## Control Layer Tests (`tests/control/`)

### VDE Channel

| Test | Coverage |
|------|----------|
| Safe | V < threshold |
| Boundary | V = threshold |
| Breach | V > threshold |
| Margin | Minimal positive margin |

### Tearing Channel

| Test | Coverage |
|------|----------|
| Safe | W < threshold |
| Boundary | W = threshold |
| Breach | W > threshold |
| Margin | Minimal positive margin |

### Composition

- Both channels safe
- One safe / one unsafe
- Both unsafe
- Failure precedence

---

## Certificate Path Tests (`tests/certificates/`)

### Test Classes

| Class | Coverage |
|-------|----------|
| Nominal | Valid cert + regime match |
| Regime boundary | Exact regime match, minimal mismatch |
| Invalidation | Expired, calibration, version |
| Adversarial | Hazard-safe but cert invalid |

### Validation Pipeline

1. EXPIRED → today > expiry
2. MISSING_SIGNATURE → signature = ""
3. INVALID_SIGNATURE_FORMAT → length < 64 or non-hex
4. MISSING_ROOT_OF_TRUST → root = ""
5. REGIME_MISMATCH → hash ≠ expected

---

## Golden Vectors (`tests/vectors/`)

### Required Vectors

| Vector | Input | Expected |
|-------|-------|----------|
| A | Valid state, cert, spend | Accept |
| B | Hazard breach | Reject (thresholdExceeded) |
| C | Cert invalid | Reject (authority) |
| D | Unaffordable | Reject (oplaxViolation) |
| E | Malformed receipt | Reject (schemaInvalid) |

### Vector Format

Each vector includes:
- Input artifact(s)
- Expected decision
- Expected reject code (if any)
- Expected replay outcome

---

## Regression Tests (`tests/regressions/`)

### Policy

Every bug fix must include a regression test:
- Named after bug class (e.g., `regression_threshold_equality`)
- Stays in canonical suite
- Documents the fix

### Known Fixed Bugs (Examples)

| Bug | File |
|-----|------|
| QFixed parse: '.' vs "." | `QFixed.lean:102` |
| matchesRegime missing | `HardwareCertificate.lean:63` |
| Semantic branching: ≥ vs > | `VerifierSemantics*.lean` |

---

## Test Matrix

| Layer | Status | Coverage |
|-------|--------|---------|
| Kernel | Pending | 9 reject codes + accept |
| Numeric | Pending | Parse, equality, overflow |
| Receipts | Pending | Parse, linkage, replay |
| Control | Pending | VDE, Tearing, composition |
| Certificates | Pending | Validation pipeline |
| Vectors | Pending | 5 golden cases |
| Regressions | Pending | Bug fixes locked |

---

## Test Execution

### Running Tests

```bash
# All tests
lake test

# Specific category
lake test tests/kernel
lake test tests/numeric
```

### Expected Outcomes

- Canonical tests: must pass
- Experimental tests: may fail
- Regression tests: must pass (forever)

---

## Maintenance

### When Tests Change

1. Document the change rationale
2. Update expected outcomes
3. Add to regression if behavioral shift
4. Update test matrix

### Test Drift Prevention

- Golden vectors reviewed per phase
- Boundary tests for every threshold
- Reject code order documented
- Regression for every bug fix

---

## Status

| Item | Status |
|------|--------|
| Test architecture | Defined |
| Folder structure | Defined |
| Kernel tests | Pending |
| Numeric tests | Pending |
| Receipt tests | Pending |
| Control tests | Pending |
| Certificate tests | Pending |
| Golden vectors | Pending |
| Regression discipline | Pending |

---

*For test matrix, see [`docs/test_matrix.md`](docs/test_matrix.md).*
*For golden vectors, see [`tests/vectors/`](tests/vectors/).*