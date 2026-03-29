# Coh-Fusion: Wedge-First Governance Architecture for Fusion Reactor Control

**STATUS: canonical**

## What This Is

Coh-Fusion is a **governance architecture** for safety-critical fusion reactor control systems. It provides a typed verification kernel that:

1. **Accepts or rejects control decisions** based on formal evidence
2. **Emits receipts** capturing the rationale for traceability
3. **Validates hardware certificates** as authority gates
4. **Freezes behavior** to known-good states for deployment

This is **not** a full tokamak control stack. It is the **software governance layer** that sits between control computation and plant execution, providing formal assurance over the decision pipeline without controlling the physics directly.

---

## What is NOT Claimed

| Claim | Status |
|-------|--------|
| **Full tokamak control stack** | ❌ Not claimed — This is a governance verifier, not a plasma control system |
| **Direct hardware certification** | ❌ Not claimed — Hardware certification is an external process; the verifier validates certificates |
| **Proof of actuator correctness** | ❌ Not claimed — Actuator execution is outside the wedge boundary |
| **Proof of raw sensor truth** | ❌ Not claimed — Sensor accuracy is assumed, not proved |

For what is explicitly excluded, see [`docs/EXCLUDED_SURFACES.md`](docs/EXCLUDED_SURFACES.md).

---

## Epistemic Posture

| Layer | Status | Scope |
|-------|--------|-------|
| Kernel | ✅ canonical | Decision verification |
| Numeric | ✅ canonical | Deterministic arithmetic only |
| Control (theorems) | ⚠️ partial | Under stated assumptions |
| Geometry | ✅ canonical | State embedding |
| Continuum | ❌ excluded | PDE dynamics outside wedge |
| Plasma physics | ❌ excluded | Full physics out of scope |

---

## Wedge Boundary

The **wedge** is the minimal buildable surface that provides governance:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        WEDGE BOUNDARY                              │
├─────────────────────────────────────────────────────────────────────┤
│  INPUT         │  CONTROL      │  CERTIFICATE   │  KERNEL         │
│  ─────        │  ──────       │  ──────────     │  ──────         │
│  State        │  Hazard      │  Authority     │  Decision      │
│  params       │  evidence    │  gate         │  verify        │
│               │              │               │                │
│  ←───         │  ───→        │  ───→          │  ────          │
│               │              │               │                │
│  OBSERVABLES  │  PROOFS      │  EVIDENCE      │  RECEIPTS      │
│  ←───         │  ───→        │  ───→          │  ───→          │
│               │              │               │                │
└─────────────────────────────────────────────────────────────────────┘
```

**Inside the wedge:**
- Decision logic (state → decision)
- Numeric arithmetic (deterministic)
- Certificate validation (formal verification)
- Receipt generation (traceability)
- Replay verification (audit)

**Outside the wedge:**
- Plant dynamics (PDEs)
- Sensor truth (hardware assumption)
- Actuator execution (firmware)
- Calibration metadata (external)

---

## Layer Ownership

Each layer has explicit ownership:

| Layer | Owner | What It Guarantees |
|-------|-------|-------------------|
| **kernel** | legality | Decision acceptance/rejection is legal |
| **numeric** | determinism | Arithmetic is exact, no floating-point |
| **control** | hazard evidence | Risk functional computation is correct |
| **certificate** | authority gating | Certificate validates before use |
| **receipt** | evidence/replay | Receipt enables audit trail |
| **tests** | behavioral freeze | Tests pin known-good behavior |

For full architecture documentation, see [`docs/architecture.md`](docs/architecture.md).

---

## Quick Start

```bash
# Build the verifier
lake build CohFusion

# Run the CLI
lean --run Main.lean

# Run tests
lake test
```

---

## Decision Flow

```
state_prev ──→ CONTROL ──→ hazard_evidence
              │                    │
              │                    ▼
              │              CERTIFICATE (validate)
              │                    │
              ▼                    ▼
         state_next ←────── KERNEL (verify)
                              │
                              ▼
                          RECEIPT (emit)
```

For detailed flow, see [`docs/kernel_flow.md`](docs/kernel_flow.md).

---

## Kernel Gates

The verifier checks in sequence:

| Gate | Check | Fail Mode |
|------|-------|----------|
| 1 | `receipt.statePrev = prevState` | UNAUTHORIZED_TRANSITION |
| 2 | `VgeomFus(params, nextState) > threshold` | THRESHOLD_EXCEEDED |
| 3 | `defectDeclared > defectLimit` | DEFECT_OUT_OF_BOUNDS |

**Boundary**: Open safe set (`>` rejects, `≤` accepts)

For the full contract, see [`docs/kernel_contract.md`](docs/kernel_contract.md).

---

## Canonical Test Suite

| Area | Tests | Status |
|------|-------|--------|
| Kernel accept | 1 | ✅ |
| Kernel reject (4 paths) | 4 | ✅ |
| Kernel boundary | 1 | ✅ |
| Certificate validation | 6 | ✅ |
| Golden vectors | 3 | ✅ |
| Regressions | 2 | ✅ |

For coverage matrix, see [`docs/test_matrix.md`](docs/test_matrix.md).

---

## Repository Structure

```
.
├── README.md                    # This file
├── lakefile.lean                 # Lean 4 package
├── lean-toolchain                # Lean version
├── Main.lean                     # CLI entry
├── src/CohFusion.lean            # Root import
├── docs/                         # Theory & spec
│   ├── architecture.md           # Layer ownership
│   ├── build_status.md           # File inventory
│   ├── proof_status.md           # Theorem status
│   ├── test_matrix.md           # Coverage
│   ├── KERNEL_SCOPE.md          # Kernel checks
│   ├── EXCLUDED_SURFACES.md      # What's outside
│   ├── ASSUMPTIONS_AND_DEPENDENCIES.md
│   ├── OPEN_RISKS.md             # Known risks
│   ├── REVIEWER_GUIDE.md        # Reading order
│   └── appendices/
└── src/CohFusion/               # Implementation
    ├── Core/                    # State, Receipt, Decision
    ├── Numeric/                # QFixed, Policy, Interval
    ├── Geometry/               # VDE, Tearing, Composition
    ├── Control/                # Hazard computation
    ├── Runtime/                # Verifier kernel
    ├── Product/                # HardwareCertificate
    ├── Schema/                 # Frame adapters
    └── Crypto/                 # Digest, Ledger
```

---

## Proof Status

The project maintains formal proofs over ℚ (rational numbers):

| Theorem | Status |
|---------|--------|
| C-4B Dissipative Descent | ⚠️ partial — under one-step descent hypothesis |
| C-2C Transversality | ✅ proved |
| C-5 Obstruction Dominance | ✅ proved |
| C-1C(b) Tearing | ✅ proved |

For full theorem inventory, see [`docs/proof_status.md`](docs/proof_status.md).

---

## Build Status

| Status | Count |
|--------|-------|
| canonical | 28 |
| draft | 4 |
| excluded | 1 |

For file-by-file status, see [`docs/build_status.md`](docs/build_status.md).

---

## What the Kernel Does NOT Check

The kernel **assumes** (does not verify):

- Observable truth (sensors are honest)
- Calibration accuracy (metadata is correct)
- Actuator execution (firmware runs correctly)
- Plant dynamics (PDEs are correct)

For the full assumption ledger, see [`docs/ASSUMPTIONS_AND_DEPENDENCIES.md`](docs/ASSUMPTIONS_AND_DEPENDENCIES.md).

---

## Open Risks

| Category | Risk |
|----------|------|
| **Technical** | Control theorem gaps (C-4B partial) |
| **Technical** | Regime matching verification |
| **Technical** | Observable sufficiency |
| **Product** | Deployment integration |
| **Product** | Explainability for operators |

For full risk inventory, see [`docs/OPEN_RISKS.md`](docs/OPEN_RISKS.md).

---

*This is a governance architecture, not a plasma physics theorem. It proves what it claims to prove and documents what it excludes.*