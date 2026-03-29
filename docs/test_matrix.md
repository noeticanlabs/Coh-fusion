# Test Matrix

## Overview

This document tracks test coverage for the canonical test suite.

---

## Test Coverage Matrix

| Layer | Category | Status | Tests |
|-------|----------|--------|-------|
| **Kernel** | Accept path | ✅ Complete | 1 |
| **Kernel** | Reject - unauthorizedTransition | ✅ Complete | 1 |
| **Kernel** | Reject - thresholdExceeded | ✅ Complete | 1 |
| **Kernel** | Reject - defectOutOfBounds | ✅ Complete | 1 |
| **Kernel** | Boundary - exact equality | ✅ Complete | 1 |
| **Numeric** | Parse valid | Pending | 0 |
| **Numeric** | Parse malformed | Pending | 0 |
| **Numeric** | Equality | Pending | 0 |
| **Numeric** | Overflow | Pending | 0 |
| **Receipts** | Parse valid | Pending | 0 |
| **Receipts** | Linkage | Pending | 0 |
| **Receipts** | Replay | Pending | 0 |
| **Control** | VDE safe | Pending | 0 |
| **Control** | VDE boundary | Pending | 0 |
| **Control** | Tearing safe | Pending | 0 |
| **Control** | Composition | Pending | 0 |
| **Certificates** | Valid | ✅ Complete | 1 |
| **Certificates** | Expired | ✅ Complete | 1 |
| **Certificates** | Missing signature | ✅ Complete | 1 |
| **Certificates** | Invalid format | ✅ Complete | 1 |
| **Certificates** | Missing root | ✅ Complete | 1 |
| **Certificates** | Regime mismatch | ✅ Complete | 1 |
| **Vectors** | Accept (A) | ✅ Complete | 1 |
| **Vectors** | Hazard reject (B) | ✅ Complete | 1 |
| **Vectors** | Authority reject (C) | ✅ Complete | 1 |
| **Vectors** | Affordability reject (D) | Pending | 0 |
| **Vectors** | Malformed (E) | Pending | 0 |
| **Regressions** | QFixed parse | ✅ Complete | 1 |
| **Regressions** | matchesRegime | ✅ Complete | 1 |

---

## Test Files Created

```
tests/
├── kernel/
│   └── kernel_basic.lean      ✅ Kernel decision tests
├── numeric/                              (pending)
├── receipts/                             (pending)
├── control/                              (pending)
├── certificates/
│   └── validation_basic.lean    ✅ Certificate validation
├── vectors/
│   ├── vector_accept.json      ✅ Golden accept
│   ├── vector_hazard_reject.json  ✅ Hazard reject
│   └── vector_authority_reject.json ✅ Authority reject
└── regressions/
    └── regression_qfixed_parse.lean ✅ Regression tests
```

---

## Status Summary

| Area | Complete | Pending |
|------|----------|---------|
| Kernel tests | 5 | 0 |
| Numeric tests | 0 | 5 |
| Receipt tests | 0 | 3 |
| Control tests | 0 | 4 |
| Certificate tests | 6 | 0 |
| Golden vectors | 3 | 2 |
| Regression tests | 2 | 0 |
| **Total** | **16** | **14** |

---

## Next Steps

1. Add numeric domain tests (parse, equality, overflow)
2. Add receipt/trace tests
3. Add control layer tests
4. Complete golden vectors (D, E)
5. Run test suite and verify outcomes

---

*For test contract, see [`docs/test_contract.md`](docs/test_contract.md).*