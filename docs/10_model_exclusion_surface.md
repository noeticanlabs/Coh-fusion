# Model Exclusion Surface

**STATUS: canonical** (superseded by `EXCLUDED_SURFACES.md`)

## Overview

The model exclusion surface explicitly documents what the Coh-Fusion architecture does **not** claim to prove or govern. This is critical for maintaining epistemic honesty about the scope of formal methods in fusion control.

## Excluded Categories

### 1. Plasma Physics Completeness

**Excluded**: Complete formalization of plasma physics

**Rationale**: Plasma physics remains an active research field with many open problems. The architecture provides governance over the **control** of plasmas, not a proof of plasma stability.

### 2. PDE Solution Existence

**Excluded**: Proof of existence/uniqueness for open-boundary PDEs

**Rationale**: This is an open mathematical research problem. The architecture works around this by:
- Using algebraic control algebra (R₀–R₄) which is mathematically closed
- Documenting PDE assumptions in `docs/` layer
- Not importing unresolved PDE proofs into Lean

### 3. Material Science

**Excluded**: Divertor physics, material interactions, surface erosion

**Rationale**: These require experimental validation, not formal methods.

### 4. Experimental Validation

**Excluded**: Empirical proof of control effectiveness

**Rationale**: The architecture is a **governance framework**, not an experimental result. It provides mathematical guarantees about the control algebra, not empirical plasma behavior.

### 5. Economic/Schedule Viability

**Excluded**: Cost optimization, construction timelines

**Rationale**: FUS-1 addresses affordability at the doctrine level (resource bounds), not at the project management level.

## Visual Representation

```
┌─────────────────────────────────────────────────────────────┐
│                   EXCLUSION SURFACE                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Plasma    │  │    PDE      │  │  Material  │          │
│  │  Physics    │  │  Existence  │  │  Science   │          │
│  │   OUT       │  │    OUT      │  │    OUT     │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Experimental│  │   Econ/     │  │  Full       │          │
│  │ Validation  │  │  Schedule   │  │  Plasma     │          │
│  │    OUT      │  │    OUT      │  │  Stability  │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │     CONTROL ALGEBRA           │
        │   (R₀–R₄, mathematically    │
        │    closed, formally proven)  │
        └───────────────────────────────┘
```

## Why This Matters

The exclusion surface is not a weakness — it is a design feature:

1. **Maintains algebraic closure** — The Lean formalization stays provable because it doesn't depend on unproven PDEs
2. **Enables honest governance** — The architecture explicitly states what it guarantees
3. **Guides future work** — The excluded areas become the "gap ledger" for future research

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md) — Layer 6 (out of scope)
- [`docs/appendices/C_gap_ledger.md`](appendices/C_gap_ledger.md) — Full gap list