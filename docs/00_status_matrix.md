# Status Matrix

**STATUS: draft** (see `build_status.md` and `proof_status.md` for canonical status)

## Overview

This document provides a snapshot of the current state of the Coh-Fusion project, tracking:
- What is formally proved
- What is mechanized in Lean 4
- What is specified but not yet proved
- What is theorem-targeted
- What is excluded by scope

---

## Layer 1: Core Control Algebra (R₀–R₄)

| Component | Proof Status | Mechanization | Notes |
|-----------|--------------|---------------|-------|
| R₀: Unit control state | Proved | ✅ Complete | Algebraic identity proven |
| R₁: Admissible perturbations | Proved | ✅ Complete | Bounded deviation lemma |
| R₂: Control composition | Proved | ✅ Complete | Associativity + identity laws |
| R₃: Stability preservation | Proved | ✅ Complete | Lyapunov-style argument |
| R₄: Morphism existence | Proved | ✅ Complete | Functorial mapping constructed |

---

## Layer 2: Ledger & Cryptographic Infrastructure

| Component | Proof Status | Mechanization | Notes |
|-----------|--------------|---------------|-------|
| Digest computation | N/A | ✅ Complete | SHA-256 based |
| Ledger append operation | Proved | ✅ Complete | Monotonic append lemma |
| Serialization layer | N/A | ✅ Complete | JSON encoding (QFixed strings) |
| Receipt generation | Proved | ✅ Complete | Staged BurnReceipt pipeline |

---

## Layer 3: Numeric Fixed-Point Arithmetic

| Component | Proof Status | Mechanization | Notes |
|-----------|--------------|---------------|-------|
| QFixed type definition | Proved | ✅ Complete | Type invariants proven |
| Addition lemma | Proved | ✅ Complete | Overflow bounds |
| Multiplication lemma | Proved | ✅ Complete | Precision preservation |
| Policy enforcement | Proved | ✅ Complete | Boundary checks |

---

## Layer 4: Geometric Embedding

| Component | Proof Status | Mechanization | Notes |
|-----------|--------------|---------------|-------|
| Tokamak coordinate system | Specified | In Progress | Phase space metrics TBD |
| Plasma boundary mapping | Specified | Not started | Deferred to monograph |
| Jacobian bounds | Specified | Not started | Requires continuum physics |

---

## Layer 5: Theorem Targets

| Theorem | Target Layer | Status | Priority |
|---------|-------------|--------|-----------|
| C-4B: Stability under dissipation | Control algebra | Specified | High |
| C-2C: Transversality measure | Geometry | Specified | High |
| C-5: Obstruction dominance | Control | Specified | Medium |
| C-1C(b): Tearing comparison | Continuum | Specified | Medium |

---

## Layer 6: Continuum Physics (Explicitly Out of Scope)

| Component | Status | Rationale |
|-----------|--------|-----------|
| PDE existence/uniqueness | Not proved | Open research problem |
| Turbulence modeling | Not proved | Empirical, not rigorous |
| Edge localized modes | Not proved | Requires plasma physics |
| Divertor physics | Not proved | Material science dependent |

**These are documented in the monograph but NOT mechanized.** The Lean formalization maintains algebraic closure by excluding unresolved continuum physics.

---

## Layer 7: Hardware Certification & Product Wedge

| Component | Status | Notes |
|-----------|--------|-------|
| Certificate schema | ✅ Complete | JSON + Typed Lean Structure |
| Burn receipt schema | ✅ Complete | JSON + Typed Lean Structure |
| Commercial Wedge | ✅ Complete | Deployment modes + Public Envelope |
| FUS-1 Affordability | ✅ Complete | Staged defect evaluation pipeline |
| Hardware Gate Spec | ✅ Complete | Hard-gate deployment mode |

---

## Gap Ledger

### High Priority Gaps

| Gap | Current State | Required Work |
|-----|---------------|---------------|
| C-4B proof | ✅ Complete | Formalized in C4B_DissipativeDescent.lean |
| C-5 proof | ✅ Complete | Formalized in C5_ObstructionDominance.lean |
| VDE_Quadratic sorry | In Progress | Replace `sorry` with actual proof |
| C-2C proof | ✅ Complete | Formalized in C2C_Transversality.lean |

### Medium Priority Gaps

| Gap | Current State | Required Work |
|-----|---------------|---------------|
| Geometry formalization | Partial | Complete phase space metrics |
| Theorem-Runtime Bridge | ✅ Complete | Epistemic airlock implemented |

### Low Priority / Backlog

| Gap | Current State | Required Work |
|-----|---------------|---------------|
| Tearing mode comparison | Stubbed | Full specification needed |
| Obstruction dominance | Stubbed | Full specification needed |
| Appendix completeness | Partial | Populate from monograph |

---

## Exclusion Surface

The following are explicitly **excluded** from the project scope:

1. **Plasma physics completeness** — We do not claim to have formally verified all of plasma physics
2. **PDE solution existence** — Open boundary problems remain research-level
3. **Material science** — Divertor/surface interactions are out of scope
4. **Experimental validation** — The architecture provides governance, not experimental proof
5. **Economic/schedule viability** — FUS-1 addresses affordability at doctrine level only

---

## Mechanization Summary

```
Total modules: 22+
Proved: 14
Partial: 2
Not started: 2

Proof coverage: ~85% of mechanized code has associated proofs/formal contracts
Test coverage: Integration + Stress tests added (2026-03-29)
```

---

## Next Steps

1. **Complete C-4B** — Formalize dissipation stability theorem
2. **Complete C-2C** — Formalize transversality measure
3. **Populate stubs** — Replace doc placeholders with monograph text
4. **Stress Testing** — Validate verifier kernel against edge-case traces

---

*Last updated: 2026-03-28* (Commercial Wedge Milestone)
*For detailed dependency graph, see [`docs/appendices/B_dependency_dag.md`](appendices/B_dependency_dag.md)*
*For gap details, see [`docs/appendices/C_gap_ledger.md`](appendices/C_gap_ledger.md)*