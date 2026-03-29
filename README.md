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

## Current Build Status

### Canonical Wedge Path

The following areas form the buildable, verified core:

| Area | Status | Notes |
|------|--------|-------|
| Core (State, Receipt, Decision, Obligations) | ✅ canonical | No proof holes |
| Numeric (QFixed, Policy, Interval) | ✅ canonical | Deterministic arithmetic |
| Geometry (VDE, Tearing, Composition) | ✅ canonical | Core failure modes |
| Runtime (VerifierSemantics, Bridge) | ✅ canonical | RV kernel |
| Product (HardwareCertificate, CommercialWedge) | ✅ canonical | Physical authorization |
| Schema (Frames, Adapters) | ✅ canonical | Data ingestion |
| Crypto (Digest, Serialize, Ledger) | ✅ canonical | Excludes dev stub |

### Draft Areas

| Area | Status | Notes |
|------|--------|-------|
| Continuum (Observables, LiftedSet, OplaxProjection) | ⚠️ draft | PDE lift placeholders |
| Control/VDE_Quadratic | ⚠️ draft | Theorem pending proof |

### Excluded Areas

| Area | Status | Notes |
|------|--------|-------|
| Crypto/DigestStub | ❌ excluded | Dev-only stub, not for production |

### Build Truth

- **No `sorry` in canonical files** — All proof holes resolved or marked as draft
- **No unresolved identifiers** — All imports resolved
- **No stale module references** — Current architecture matches file contents

For detailed file-by-file status, see [`docs/build_status.md`](docs/build_status.md).
For what the build includes/excludes, see [`docs/build_scope.md`](docs/build_scope.md).

### Canonical Verifier Path

The Coh-Fusion verifier has exactly **one canonical kernel**:

| Component | File | Notes |
|-----------|------|-------|
| **Kernel** | `Runtime/VerifierSemanticsQFixed.lean` | QFixed implementation (canonical) |
| Generic wrapper | `Runtime/VerifierSemantics.lean` | Template (draft) |
| Product wrapper | `Product/CommercialWedge.lean` | Calls kernel |
| Bridge | `Runtime/Bridge.lean` | Calls kernel |

**Kernel Gates (in order):**

1. **State Link** — `receipt.statePrev = prevState`
2. **Threshold** — `VgeomFus(params, nextState) > threshold` → reject
3. **Defect** — `defectDeclared > defectLimit` → reject  
4. **Oplax** — `V(next) > V(prev) - (1-γ)*spend + defect` → reject

- **Open safe set**: `>` triggers rejection, `≤` accepts
- **Order**: Gates checked in fixed sequence, first failure wins

For detailed contract, see [`docs/kernel_contract.md`](docs/kernel_contract.md).
For operational flow, see [`docs/kernel_flow.md`](docs/kernel_flow.md).

### Canonical Numeric Domain

The verifier uses **QFixed** (Q64.64 fixed-point) as the canonical numeric domain:

| Property | Value |
|----------|-------|
| Format | Fixed-point (2^64 scale) |
| Internal | Lean `Int` (arbitrary precision) |
| Comparison | Exact integer comparison |
| Float | **Banned** from kernel |
| Parse | `fromDecimalString` — exact decimal |

**Boundary Semantics**: Open safe set (`>` rejects, `≤` accepts)

For detailed numeric contract, see [`docs/numeric_contract.md`](docs/numeric_contract.md).
For numeric flow, see [`docs/numeric_flow.md`](docs/numeric_flow.md).

### Receipt and Replay Model

The verifier emits canonical **MicroReceipt** for each transition:

| Component | File | Notes |
|-----------|------|-------|
| **Receipt** | `Core/Receipt.lean` | `MicroReceipt` (canonical) |
| **Replay** | `Runtime/VerifierSemanticsQFixed.lean` | Recomputes decision |
| **Trace** | `Runtime/Bridge.lean` | Sequential check |

**Receipt binds**: statePrev → stateNext → spend → defect

**Replay**: Reconstruct decision from receipt + kernel policy. Decision must match.

**Proof scope**: What the receipt proves — decision legality, state linkage, numeric evidence. What it does NOT prove — sensor accuracy, physical plant state.

For detailed receipt contract, see [`docs/receipt_contract.md`](docs/receipt_contract.md).
For receipt flow, see [`docs/receipt_flow.md`](docs/receipt_flow.md).

### Control Layer

The control layer computes **canonical hazard evidence** for the kernel:

| Channel | Risk Functional | Threshold | Margin |
|---------|-----------------|------------|--------|
| VDE | `ω1·Z² + ω2·vZ² + ω3·I_act²` | `Theta_V` | `Theta_V - risk` |
| Tearing | `ν1·W² + ν2·vW² + ν3·I_cd²` | `Theta_T` | `Theta_T - risk` |

**Composition**: Conjunctive — both channels must be safe
**Margin convention**: Positive = safe slack, zero = boundary, negative = breach

Control does NOT make final legality decisions — it provides evidence to the kernel.

For detailed control contract, see [`docs/control_contract.md`](docs/control_contract.md).
For control flow, see [`docs/control_flow.md`](docs/control_flow.md).

### Hardware Certificate Path

The hardware certificate is a **first-class authority gate** in the typed tower:

| Component | Purpose |
|------------|----------|
| `HardwareCertificate` | Typed certificate structure with performance limits |
| `validateCertificate` | Full validation pipeline |
| `Certificate in Wedge` | Embedded as authority gate |

**Certificate Validation Gates**:

| Check | Function | Failure |
|-------|----------|--------|
| Expiry | `isExpired` | CERT_EXPIRED |
| Signature | `hasValidSignatureFormat` | INVALID_SIGNATURE_FORMAT |
| Root of Trust | `hasRootOfTrust` | MISSING_ROOT_OF_TRUST |
| Regime Match | `matchesRegime` | REGIME_MISMATCH |

**Certificate Flow**: Hardware provision → Issuance → Regime binding → Validation → Verifier consumption

For detailed certificate contract, see [`docs/certificate_contract.md`](docs/certificate_contract.md).
For certificate flow, see [`docs/certificate_flow.md`](docs/certificate_flow.md).

### Canonical Test Suite

The canonical test suite freezes the wedge's operational behavior:

| Area | Coverage |
|------|----------|
| Kernel | 5 tests (accept + 4 reject paths + boundary) |
| Certificates | 6 tests (validation pipeline) |
| Vectors | 3 golden cases (accept, hazard, authority) |
| Regressions | 2 tests (QFixed parse, matchesRegime) |

**Test Structure**:

- `tests/kernel/` — Kernel decision tests
- `tests/certificates/` — Certificate validation tests
- `tests/vectors/` — Golden end-to-end vectors (JSON)
- `tests/regressions/` — Bug fix regression tests

For detailed test contract, see [`docs/test_contract.md`](docs/test_contract.md).
For test coverage matrix, see [`docs/test_matrix.md`](docs/test_matrix.md).

---

*For the full technical specification, see the monograph and associated gap ledger in `docs/appendices/`.*