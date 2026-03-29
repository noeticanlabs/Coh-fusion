# Build Status Ledger

## Overview

This document provides the canonical file-level inventory for the Coh-Fusion project,
tracking build status, role, and required actions for each source file.

**Phase 1 Goal:** Get the repo into a state where every canonical file compiles or is
explicitly marked non-canonical, with no hidden proof holes.

---

## File Inventory

| File Path | Area | Role | Status | Blocker | Action Required |
|-----------|------|------|--------|---------|------------------|
| **Core** |||||
| `src/CohFusion/Core/State.lean` | Core | Flat state definition | canonical | none | — |
| `src/CohFusion/Core/Receipt.lean` | Core | Receipt structures | canonical | none | — |
| `src/CohFusion/Core/Decision.lean` | Core | Decision monad | canonical | none | — |
| `src/CohFusion/Core/CohObject.lean` | Core | Class interface | canonical | none | — |
| `src/CohFusion/Core/Obligations.lean` | Core | Soundness predicates | canonical | none | — |
| **Numeric** |||||
| `src/CohFusion/Numeric/QFixed.lean` | Numeric | Fixed-point arithmetic | canonical | none | — |
| `src/CohFusion/Numeric/Policy.lean` | Numeric | Consensus-safe typeclass | canonical | none | — |
| `src/CohFusion/Numeric/Interval.lean` | Numeric | Interval bounds | canonical | none | — |
| `src/CohFusion/Numeric/BoundsAxioms.lean` | Numeric | Bounds evaluation | canonical | none | — |
| `src/CohFusion/Numeric/Serialize.lean` | Numeric | JSON serialization | canonical | none | — |
| **Geometry** |||||
| `src/CohFusion/Geometry/VDECore.lean` | Geometry | VDE state/params | canonical | none | — |
| `src/CohFusion/Geometry/VDERuntime.lean` | Geometry | VDE runtime ops | canonical | none | — |
| `src/CohFusion/Geometry/TearingCore.lean` | Geometry | Tearing state/params | canonical | none | — |
| `src/CohFusion/Geometry/TearingRuntime.lean` | Geometry | Tearing runtime ops | canonical | none | — |
| `src/CohFusion/Geometry/Composition.lean` | Geometry | Joint state/params | canonical | none | — |
| `src/CohFusion/Geometry/Theorems/C2C_Transversality.lean` | Geometry | C-2C theorem (Q) | canonical | none | — |
| **Control** |||||
| `src/CohFusion/Control/VDE_Abstract.lean` | Control | VDE abstract predicates | canonical | none | — |
| `src/CohFusion/Control/VDE_Quadratic.lean` | Control | VDE quadratic synthesis | **draft** | theorem pending | Complete proof for `synthesized_control_contracts` |
| `src/CohFusion/Control/Tearing_Quadratic.lean` | Control | Tearing quadratic synthesis | canonical | none | — |
| `src/CohFusion/Control/Composition.lean` | Control | Control composition | canonical | none | — |
| `src/CohFusion/Control/BurnContract.lean` | Control | Burn contract | canonical | none | — |
| `src/CohFusion/Control/BurnPolicyDemo.lean` | Control | Demo policy | canonical | none | — |
| `src/CohFusion/Control/Theorems/C4B_DissipativeDescent.lean` | Control | C-4B kernel (Q) | canonical | none | — |
| `src/CohFusion/Control/Theorems/C4B_VDE.lean` | Control | C-4B VDE (Q) | canonical | none | — |
| `src/CohFusion/Control/Theorems/C4B_Tearing.lean` | Control | C-4B Tearing (Q) | canonical | none | — |
| **Runtime** |||||
| `src/CohFusion/Runtime/VerifierSemantics.lean` | Runtime | RV kernel (generic) | canonical | none | — |
| `src/CohFusion/Runtime/VerifierSemanticsQFixed.lean` | Runtime | RV kernel (QFixed) | canonical | none | — |
| `src/CohFusion/Runtime/Bridge.lean` | Runtime | Runtime bridge | canonical | none | — |
| `src/CohFusion/Runtime/HashBoundedReceipt.lean` | Runtime | Hash-bounded receipt | canonical | none | — |
| **Product** |||||
| `src/CohFusion/Product/HardwareCertificate.lean` | Product | Hardware cert schema | canonical | none | — |
| `src/CohFusion/Product/CommercialWedge.lean` | Product | Commercial wedge | canonical | none | — |
| **Schema** |||||
| `src/CohFusion/Schema/Frames.lean` | Schema | Dataset frame structures | canonical | none | — |
| `src/CohFusion/Schema/Adapters.lean` | Schema | Frame adapters | canonical | none | — |
| **Crypto** |||||
| `src/CohFusion/Crypto/Digest.lean` | Crypto | Digest type | canonical | none | — |
| `src/CohFusion/Crypto/DigestStub.lean` | Crypto | Dev stub | **excluded** | non-prod | Keep isolated, not in main build |
| `src/CohFusion/Crypto/Serialize.lean` | Crypto | Serialization interface | canonical | none | — |
| `src/CohFusion/Crypto/Ledger.lean` | Crypto | Burn receipt ledger | canonical | none | — |
| **Continuum** |||||
| `src/CohFusion/Continuum/Observables.lean` | Continuum | Observable signatures | **draft** | PDE lift incomplete | Mark as draft |
| `src/CohFusion/Continuum/LiftedSet.lean` | Continuum | Lifted set signatures | **draft** | PDE lift incomplete | Mark as draft |
| `src/CohFusion/Continuum/OplaxProjection.lean` | Continuum | Oplax projection | **draft** | PDE lift incomplete | Mark as draft |
| **Root & Entry** |||||
| `src/CohFusion.lean` | Root | Main re-exports | canonical | none | — |
| `Main.lean` | Entry | Executable entry | canonical | none | — |

---

## Hard Blocker Summary

### Proof Holes

| File | Location | Issue |
|------|----------|-------|
| `src/CohFusion/Control/VDE_Quadratic.lean` | line 68 | `synthesized_control_contracts` uses `by sorry` |

### Resolution

- **Option A**: Complete the proof (requires substantial work)
- **Option B**: Mark file as `draft` and remove from canonical build path

---

## Build Status Summary

| Status | Count |
|--------|-------|
| canonical | 28 |
| draft | 4 |
| excluded | 1 |

### Canonical Wedge Path

The minimal wedge path for a buildable system:

1. **Numeric** → **Core** → **Geometry** → **Runtime** → **Product**
2. **Control** provides theorem layer (over ℚ rational shadow)
3. **Schema** provides data ingestion layer
4. **Crypto** provides digest interface

### Draft Areas

- `Continuum/*` — PDE lift signatures (placeholder abstractions)
- `Control/VDE_Quadratic.lean` — Theorem pending proof

### Excluded Areas

- `Crypto/DigestStub.lean` — Dev-only stub, not for production

---

## Next Steps (Phase 1)

1. ~~Inventory the repo truthfully~~ ✓ Complete
2. ~~Detect all hard blockers~~ ✓ Complete
3. Classify files by status — **IN PROGRESS**
4. Fix compile-surface blockers — Pending decision on VDE_Quadratic
5. Quarantine non-canonical surfaces — Pending
6. Publish the build truth ledger — Pending

---

## Notes

- All theorem files operate over ℚ (rational numbers) as "rational shadow" models
- The actual executable uses QFixed (fixed-point arithmetic)
- The bridge between theorem (Q) and runtime (QFixed) is intentionally narrow
- No `sorry` or `admit` should remain in canonical files

---

*Last updated: 2026-03-29*
