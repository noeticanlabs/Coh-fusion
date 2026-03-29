# Build Status Ledger

**STATUS: canonical**

## Overview

This document provides the canonical file-level inventory for the Coh-Fusion project, tracking build status, role, and required actions for each source file.

---

## File Inventory

### Core Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Core/State.lean` | Core | Flat state definition | canonical | none | — |
| `src/CohFusion/Core/Receipt.lean` | Core | Receipt structures | canonical | none | — |
| `src/CohFusion/Core/Decision.lean` | Core | Decision monad | canonical | none | — |
| `src/CohFusion/Core/CohObject.lean` | Core | Class interface | canonical | none | — |
| `src/CohFusion/Core/Obligations.lean` | Core | Soundness predicates | canonical | none | — |

### Numeric Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Numeric/QFixed.lean` | Numeric | Fixed-point arithmetic | canonical | none | — |
| `src/CohFusion/Numeric/Policy.lean` | Numeric | Consensus-safe typeclass | canonical | none | — |
| `src/CohFusion/Numeric/Interval.lean` | Numeric | Interval bounds | canonical | none | — |
| `src/CohFusion/Numeric/BoundsAxioms.lean` | Numeric | Bounds evaluation | canonical | none | — |
| `src/CohFusion/Numeric/Serialize.lean` | Numeric | JSON serialization | canonical | none | — |

### Geometry Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Geometry/VDECore.lean` | Geometry | VDE state/params | canonical | none | — |
| `src/CohFusion/Geometry/VDERuntime.lean` | Geometry | VDE runtime ops | canonical | none | — |
| `src/CohFusion/Geometry/TearingCore.lean` | Geometry | Tearing state/params | canonical | none | — |
| `src/CohFusion/Geometry/TearingRuntime.lean` | Geometry | Tearing runtime ops | canonical | none | — |
| `src/CohFusion/Geometry/Composition.lean` | Geometry | Joint state/params | canonical | none | — |
| `src/CohFusion/Geometry/Theorems/C2C_Transversality.lean` | Geometry | C-2C theorem (Q) | canonical | none | — |

### Control Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Control/VDE_Abstract.lean` | Control | VDE abstract predicates | canonical | none | — |
| `src/CohFusion/Control/VDE_Quadratic.lean` | Control | VDE quadratic synthesis | **draft** | theorem pending | Complete proof for `synthesized_control_contracts` |
| `src/CohFusion/Control/Tearing_Quadratic.lean` | Control | Tearing quadratic synthesis | canonical | none | — |
| `src/CohFusion/Control/Composition.lean` | Control | Control composition | canonical | none | — |
| `src/CohFusion/Control/BurnContract.lean` | Control | Burn contract | canonical | none | — |
| `src/CohFusion/Control/BurnPolicyDemo.lean` | Control | Demo policy | canonical | none | — |
| `src/CohFusion/Control/Theorems/C4B_DissipativeDescent.lean` | Control | C-4B kernel (Q) | **draft** | partial proof | Complete hypothesis resolution |
| `src/CohFusion/Control/Theorems/C4B_VDE.lean` | Control | C-4B VDE (Q) | **draft** | partial proof | Complete hypothesis resolution |
| `src/CohFusion/Control/Theorems/C4B_Tearing.lean` | Control | C-4B Tearing (Q) | **draft** | partial proof | Complete hypothesis resolution |

### Runtime Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Runtime/VerifierSemantics.lean` | Runtime | RV kernel (generic) | canonical | none | — |
| `src/CohFusion/Runtime/VerifierSemanticsQFixed.lean` | Runtime | RV kernel (QFixed) | canonical | none | — |
| `src/CohFusion/Runtime/Bridge.lean` | Runtime | Runtime bridge | canonical | none | — |
| `src/CohFusion/Runtime/HashBoundedReceipt.lean` | Runtime | Hash-bounded receipt | canonical | none | — |

### Product Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Product/HardwareCertificate.lean` | Product | Hardware cert schema | canonical | none | — |
| `src/CohFusion/Product/CommercialWedge.lean` | Product | Commercial wedge | canonical | none | — |

### Schema Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Schema/Frames.lean` | Schema | Dataset frame structures | canonical | none | — |
| `src/CohFusion/Schema/Adapters.lean` | Schema | Frame adapters | canonical | none | — |

### Crypto Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Crypto/Digest.lean` | Crypto | Digest type | canonical | none | — |
| `src/CohFusion/Crypto/DigestStub.lean` | Crypto | Dev stub | **excluded** | non-prod | Keep isolated, not in main build |
| `src/CohFusion/Crypto/Serialize.lean` | Crypto | Serialization interface | canonical | none | — |
| `src/CohFusion/Crypto/Ledger.lean` | Crypto | Burn receipt ledger | canonical | none | — |

### Continuum Layer

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion/Continuum/Observables.lean` | Continuum | Observable signatures | **draft** | PDE lift incomplete | Mark as draft |
| `src/CohFusion/Continuum/LiftedSet.lean` | Continuum | Lifted set signatures | **draft** | PDE lift incomplete | Mark as draft |
| `src/CohFusion/Continuum/OplaxProjection.lean` | Continuum | Oplax projection | **draft** | PDE lift incomplete | Mark as draft |

### Root & Entry

| File Path | Area | Role | Status | Blocker | Action Required |
|----------|------|------|--------|---------|------------------|
| `src/CohFusion.lean` | Root | Main re-exports | canonical | none | — |
| `Main.lean` | Entry | Executable entry | canonical | none | — |

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

---

## What is NOT Built

### Excluded Files

| File | Reason |
|------|--------|
| `src/CohFusion/Crypto/DigestStub.lean` | Dev-only stub, not for production |

### Draft Files (Build With Warnings)

| File | Reason |
|------|--------|
| `src/CohFusion/Control/VDE_Quadratic.lean` | Theorem pending proof |
| `src/CohFusion/Control/Theorems/C4B_DissipativeDescent.lean` | Partial proof (hypothesis unresolved) |
| `src/CohFusion/Control/Theorems/C4B_VDE.lean` | Partial proof (hypothesis unresolved) |
| `src/CohFusion/Control/Theorems/C4B_Tearing.lean` | Partial proof (hypothesis unresolved) |
| `src/CohFusion/Continuum/Observables.lean` | PDE lift incomplete |
| `src/CohFusion/Continuum/LiftedSet.lean` | PDE lift incomplete |
| `src/CohFusion/Continuum/OplaxProjection.lean` | PDE lift incomplete |

---

## Build Truth

- **No `sorry` in canonical files** — All proof holes resolved or marked as draft
- **No unresolved identifiers** — All imports resolved
- **No stale module references** — Current architecture matches file contents
- **No float in kernel** — QFixed is the canonical numeric domain
