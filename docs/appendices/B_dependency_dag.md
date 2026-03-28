# Appendix B: Dependency DAG

## Overview

This document shows the dependency relationships between the major components of the Coh-Fusion architecture.

## Layer Dependency Graph

```
                        ┌─────────────────────┐
                        │   Model Exclusion   │
                        │      Surface        │
                        │    (doc layer)      │
                        └──────────┬──────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
              ▼                    ▼                    ▼
┌─────────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  FUS-1 Affordability│  │ Hardware Cert   │  │ Theorem Targets │
│      Doctrine       │  │    Layer        │  │  (C-4B, C-2C,   │
│    (doc + src/)     │  │  (doc + src/)   │  │   C-5, C-1C(b)) │
└─────────┬───────────┘  └────────┬────────┘  └────────┬────────┘
          │                       │                      │
          │                       │                      │
          ▼                       ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CONTINUUM LAYER                              │
│  (Tearing / Transversality / Open Boundary - doc only)         │
└─────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GEOMETRY LAYER                               │
│  (Tokamak coordinates / Phase space - in progress)            │
└─────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                     CORE LAYER                                  │
│   R₀ ──► R₁ ──► R₂ ──► R₃ ──► R₄                               │
│   (Lean mechanized - complete)                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Lean Module Dependencies

```
CohFusion.lean (root)
  │
  ├── src/CohFusion.lean
  │     │
  │     ├── CohFusion/Numeric.lean
  │     │     ├── QFixed.lean
  │     │     ├── Interval.lean
  │     │     └── Policy.lean
  │     │
  │     ├── CohFusion/Crypto.lean
  │     │     ├── Digest.lean
  │     │     ├── Ledger.lean
  │     │     └── Serialize.lean
  │     │
  │     └── CohFusion/Base.lean
  │           ├── CohObject.lean
  │           ├── Obligations.lean
  │           └── VerifierResult.lean
  │
  └── (future: Core/, Geometry/, Control/, Continuum/, Runtime/)
```

## Cross-Layer Dependencies

| From Layer | To Layer | Dependency Type |
|------------|----------|-----------------|
| Core (R₀–R₄) | Geometry | Uses coordinate transformations |
| Geometry | Continuum | References boundary conditions |
| Theorem Targets | Core | Depend on R₃ stability |
| Hardware Cert | Core | Validates control morphisms |
| FUS-1 | Hardware Cert | Resource budget enforcement |

## Build Dependencies

- `lake build` requires: mathlib v4.25.0
- Lean toolchain: 4.25.0
- JSON schemas: Used at runtime, not compile time

## Status

- Core layer: Fully mechanized
- Geometry layer: Partial (in progress)
- Theorem targets: Specified but not mechanized
- Continuum layer: Documented only (out of scope)