# Appendix C: Gap Ledger

## Overview

This document provides a detailed catalog of the gaps in the Coh-Fusion project - areas that are specified but not yet mechanized, proved, or implemented.

---

## High Priority Gaps

### Lean Tree Refactor

**Description**: The current Lean source is in a single `src/` directory. It needs to be split into:
- `src/CohFusion/Core/` — R₀–R₄ morphisms
- `src/CohFusion/Geometry/` — Tokamak embedding
- `src/CohFusion/Control/` — Control algebra theorems
- `src/CohFusion/Continuum/` — PDE/boundary specs
- `src/CohFusion/Runtime/` — Verifier kernel

**Current State**: Single flat directory structure
**Required Work**: Directory creation, file migration, import rewiring
**Blocking**: Build validation, theorem mechanization

---

### C-4B Dissipation Stability Proof

**Description**: Formal proof that bounded dissipation operators preserve stability

**Current State**: Specification complete, not started
**Required Work**: 
- Spectral radius formalization in Lean
- Composition stability lemma
- Induction framework

**Priority**: High

---

### C-2C Transversality Proof

**Description**: Formal proof that control perturbations are transverse to plasma boundary

**Current State**: Specification complete, not started
**Required Work**:
- Manifold theory in Lean
- Measure theory for zero-measure proofs
- Coordinate transformation lemmas

**Priority**: High

---

### Import Graph Validation

**Description**: Fix the broken Lean import graph causing build failures

**Current State**: Lake setup fails due to proofwidgets version mismatch
**Required Work**:
- Resolve dependency conflicts
- Validate all imports compile
- Test with `lake build`

**Priority**: High

---

## Medium Priority Gaps

### Geometry Layer Formalization

**Description**: Complete the geometric embedding of tokamak phase space

**Current State**: Partial (in progress)
**Required Work**:
- Phase space metric definition
- Jacobian bounds proofs
- Boundary manifold formalization

**Priority**: Medium

---

### Hardware Certificate Validation

**Description**: Implement the runtime validator for hardware certificates

**Current State**: Schema defined, logic stubbed
**Required Work**:
- JSON parsing/validation
- Signature verification against root of trust
- Timestamp validity checks

**Priority**: Medium

---

### Receipt Verification Kernel

**Description**: Implement the runtime verifier for burn receipts

**Current State**: Schema defined, logic stubbed
**Required Work**:
- Receipt parsing
- Integrity hash verification
- Resource bound checking

**Priority**: Medium

---

### FUS-1 Full Doctrine Text

**Description**: Replace placeholder FUS-1 doc with full monograph text

**Current State**: Stub/summary only
**Required Work**:
- Full principle elaboration
- Mode-specific bounds
- Examples and edge cases

**Priority**: Medium

---

## Low Priority / Backlog Gaps

### C-5 Obstruction Dominance

**Description**: Formalize obstruction classification and dominance proofs

**Current State**: Specified
**Required Work**: Full specification + proof
**Priority**: Low

---

### C-1C(b) Tearing Comparison

**Description**: Formalize tearing index comparison with physical modes

**Current State**: Specified with explicit scope note
**Required Work**: Full specification
**Priority**: Low

---

### Appendix Completeness

**Description**: Populate remaining appendices from monograph

**Current State**: Partial
**Required Work**: Full prose for all appendices
**Priority**: Low

---

## Explicitly Excluded (Not Gaps)

These are **intentionally not in scope** and are not considered gaps:

1. Plasma physics completeness
2. PDE solution existence proofs
3. Material science formalization
4. Experimental validation
5. Economic/schedule optimization

See [`docs/10_model_exclusion_surface.md`](10_model_exclusion_surface.md)

---

## Gap Summary

| Priority | Count | Status |
|----------|-------|--------|
| High | 4 | Not started |
| Medium | 4 | Partial/stubbed |
| Low | 3 | Specified |

---

*Last updated: 2026-03-28*