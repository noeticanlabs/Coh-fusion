# Coh-Fusion: Governance Architecture for Fusion Reactor Control

## Project Identity

Coh-Fusion is a formal governance architecture for safety-critical fusion reactor control systems. The project mechanizes a typed tower of correctness guarantees spanning:

- **Algebraic closure** of the control algebra (R₀–R₄ morphological bridge)
- **Geometric embedding** of tokamak plasma states
- **Continuum physically justified** dynamics with rigorous boundary handling

This is **not** a claim of complete plasma physics mastery. It is a governance architecture that formalizes the **control-theoretic core** of reactor operation while explicitly deferring unresolved continuum physics questions to the specification layer.

## Epistemic Posture

| Layer | Status |
|-------|--------|
| Algebraic core (R₀–R₄) | Mechanized in Lean 4 |
| Geometric embedding | In progress |
| Control theoretic guarantees | Theorem-targeted |
| Continuum PDE boundary | Specified but not mechanized |
| Plasma physics completeness | **Out of scope** — deferred to monograph |

The project maintains a strict separation:
- `docs/` = theory/specification (may reference unresolved physics)
- `lean4/` = formalization (algebraically closed core only)
- `src/` = runtime verifier (no physics inheritance)

## Typed Tower Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    GOVERNANCE LAYER                         │
│  (FUS-1 Affordability Doctrine / Model Exclusion Surface)  │
├─────────────────────────────────────────────────────────────┤
│                   HARDWARE CERTIFICATION                   │
│     (Observable Sufficiency / Burn Receipt / Gate Spec)    │
├─────────────────────────────────────────────────────────────┤
│                    THEOREM TARGETS                          │
│  C-4B │ C-2C │ C-5 │ C-1C(b) │ Morphological Bridge       │
├─────────────────────────────────────────────────────────────┤
│                   CONTINUUM LAYER                           │
│     (Open Boundary / Tearing / Transversality Tracks)      │
├─────────────────────────────────────────────────────────────┤
│                   GEOMETRY LAYER                            │
│         (Tokamak Embedding / Phase Space Metrics)          │
├─────────────────────────────────────────────────────────────┤
│                     CORE LAYER                              │
│    (R₀–R₄ Morphisms / Control Algebra / Ledger Rigidity)  │
└─────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
.
├── README.md                    # This file
├── lakefile.lean               # Lean 4 package definition
├── lean-toolchain              # Lean version pin
├── CohFusion.lean              # Root import surface (entry point)
├── Main.lean                   # CLI entrypoint
├── docs/                       # Theory & specification layer
│   ├── 00_status_matrix.md     # Proof / mechanization / gap status
│   ├── 06a_r0_r4_morphological_bridge.md
│   ├── 06b_c4b_theorem_target.md
│   ├── 06c_c2c_transversality_track.md
│   ├── 06d_c5_obstruction_dominance.md
│   ├── 06e_c1cb_tearing_comparison.md
│   ├── 07a_hardware_certification.md
│   ├── 07b_observable_stress_tests.md
│   ├── 07c_fus1_affordability.md
│   ├── 10_model_exclusion_surface.md
│   └── appendices/
│       ├── A_notation_ledger.md
│       ├── B_dependency_dag.md
│       ├── C_gap_ledger.md
│       └── D_canonical_receipt_encoding.md
├── src/                        # Runtime implementation layer
│   └── CohFusion/
│       ├── Base/
│       │   ├── CohObject.lean
│       │   ├── Obligations.lean
│       │   └── VerifierResult.lean
│       ├── Crypto/
│       │   ├── Digest.lean
│       │   ├── Ledger.lean
│       │   └── Serialize.lean
│       └── Numeric/
│           ├── Interval.lean
│           ├── Policy.lean
│           ├── QFixed.lean
│           └── Serialize.lean
└── lean4/                     # [Reserved] Future Lean source split
```

## Layer Separation Rationale

### Why this matters

The **epistemic airlock** between layers is deliberate:

1. **PDE/open-boundary material does not contaminate the verifier kernel** — The runtime verifier (`src/`) must not inherit unresolved plasma physics assumptions. It operates on formally verified algebraic guarantees only.

2. **Runtime does not prove continuum physics** — The `src/` layer implements the **software contract** of the governance architecture. It validates receipts, checks certificates, and enforces policy — it does not claim to prove plasma stability.

3. **Lean formalization stays algebraically closed** — The `lean4/` (or `src/`) Lean files formalize the **control-theoretic core** that is mathematically closed. Unresolved PDE questions are documented in `docs/` but not imported into the formalization.

## Building the Project

```bash
# Install dependencies
lake env

# Build the Lean library
lake build CohFusion

# Run the CLI entrypoint
lean --run Main.lean
```

## Status Summary

| Component | Status |
|-----------|--------|
| Core control algebra (R₀–R₄) | Mechanized |
| Ledger / receipt infrastructure | Implemented |
| Numeric fixed-point arithmetic | Implemented |
| Geometric embedding | In progress |
| Theorem targets (C-4B, C-2C, C-5) | Specified |
| Hardware certification layer | Specified |
| Runtime verifier kernel | Partial |

See [`docs/00_status_matrix.md`](docs/00_status_matrix.md) for the full gap ledger.

## Governance Claim

This project demonstrates that **formal methods can govern fusion control** without requiring complete plasma physics formalization. The architecture achieves:

- **Algebraic closure** of the control layer
- **Runtime verification** of hardware certificates
- **Explicit scope boundaries** (what is and is not proved)

This is a **governance architecture**, not a plasma physics theorem. The typed tower proves what it claims to prove, and documents what it deliberately excludes.

---

*For the full technical specification, see the monograph and associated gap ledger in `docs/appendices/`.*