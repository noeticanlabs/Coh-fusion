# Kernel Boundary

**STATUS: canonical** (superseded by `KERNEL_SCOPE.md`)

This document defines the explicit boundary of the Coh-Fusion kernel—what constitutes the authoritative, certified, and verifier-bound core of the system.

---

## Definition: "Authoritative"

**Authoritative** means:
- The kernel is the only component whose execution determines acceptance/rejection decisions
- Kernel code is formally verified or certified against a hardware attestation
- Artifacts cannot override or bypass kernel logic
- The kernel's decision is final and binding for regulatory purposes

---

## Explicit Kernel Files

The following files constitute the Coh-Fusion kernel:

### Core Layer

| File | Purpose |
|------|---------|
| `src/CohFusion/Core/State.lean` | State6 definition (flat verifier-visible state) |
| `src/CohFusion/Core/Receipt.lean` | FusionReceipt definition and transformations |
| `src/CohFusion/Core/Decision.lean` | Decision type (accept/reject with codes) |

### Numeric Layer

| File | Purpose |
|------|---------|
| `src/CohFusion/Numeric/QFixed.lean` | Fixed-point arithmetic primitives |
| `src/CohFusion/Numeric/Policy.lean` | Risk functional VgeomFus definition |
| `src/CohFusion/Numeric/BoundsAxioms.lean` | Bounds checking and validation axioms |

### Geometry Layer

| File | Purpose |
|------|---------|
| `src/CohFusion/Geometry/VDECore.lean` | VDE core geometric definitions |
| `src/CohFusion/Geometry/TearingCore.lean` | Tearing core geometric definitions |
| `src/CohFusion/Geometry/Composition.lean` | Composition of geometric operators |

### Runtime Layer

| File | Purpose |
|------|---------|
| `src/CohFusion/Runtime/VerifierSemantics.lean` | Generic verifyRV kernel |
| `src/CohFusion/Runtime/VerifierSemanticsQFixed.lean` | QFixed-specific verifyRV_QFixed |
| `src/CohFusion/Runtime/Bridge.lean` | Trace verification bridge |

### Product Layer

| File | Purpose |
|------|---------|
| `src/CohFusion/Product/CommercialWedge.lean` | Commercial wedge product definition |

---

## Non-Kernel Files (Artifacts Layer)

The following are **NOT** part of the kernel and are considered artifacts:

### Crypto Layer

| File | Purpose | Notes |
|------|---------|-------|
| `src/CohFusion/Crypto/Digest.lean` | Cryptographic digests | Artifacts layer |
| `src/CohFusion/Crypto/Ledger.lean` | Ledger/float arithmetic | **Acceptable**: float in ledger is acceptable |
| `src/CohFusion/Crypto/Serialize.lean` | Serialization | Artifacts layer |

**Note**: The ledger using floating-point is acceptable as it operates outside the critical decision path.

### Continuum Layer

| File | Purpose |
|------|---------|
| `src/CohFusion/Continuum/LiftedSet.lean` | Continuum/lifted set theory |
| `src/CohFusion/Continuum/Observables.lean` | Observable extensions |
| `src/CohFusion/Continuum/OplaxProjection.lean` | Oplax projections |

### Runtime Layer (Archival)

| File | Purpose | Notes |
|------|---------|-------|
| `src/CohFusion/Runtime/HashBoundedReceipt.lean` | Hash-bounded receipt | **Deprecated**: archival wrapper, kept for backwards compatibility |

---

## Boundary Rules

### What Is Inside the Kernel

1. **State definitions** — State6, FusionReceipt, Decision
2. **Risk functional** — VgeomFus computation
3. **Verification logic** — verifyRV, verifyRV_QFixed
4. **Bounds checking** — Threshold, defect limit, oplax inequality
5. **Trace linkage** — Sequential receipt chaining

### What Is Outside the Kernel

1. **Floating-point arithmetic** — Only acceptable in ledger, not kernel
2. **Serialization** — Artifact for storage/transport
3. **Cryptographic hashing** — Optional chain binding, not required for MVP
4. **Continuum theory** — Beyond verifier-visible observables
5. **Historical receipts** — HashBoundedReceipt for archival

---

## Certification Implications

### Kernel Certification

The kernel files listed above are the only components that require:
- Hardware certification (via HardwareCertificate)
- Formal verification
- Regulatory audit

### Artifacts Exclusion

Artifacts (non-kernel files) do NOT require:
- Hardware certification for re-verification
- Formal verification (may be tested)
- Regulatory audit (documentary only)

---

## Dependency Graph

```
Kernel (Authoritative)
├── Core/State.lean
├── Core/Receipt.lean
├── Core/Decision.lean
├── Numeric/QFixed.lean
├── Numeric/Policy.lean
├── Numeric/BoundsAxioms.lean
├── Geometry/VDECore.lean
├── Geometry/TearingCore.lean
├── Geometry/Composition.lean
├── Runtime/VerifierSemantics.lean
├── Runtime/VerifierSemanticsQFixed.lean
├── Runtime/Bridge.lean
└── Product/CommercialWedge.lean

Artifacts (Non-Authoritative)
├── Crypto/*
├── Continuum/*
└── Runtime/HashBoundedReceipt.lean
```

---

## Revision History

| Date | Change |
|------|--------|
| 2026-03-29 | Initial kernel boundary definition |
| 2026-03-29 | Added FusionReceipt as canonical receipt type |