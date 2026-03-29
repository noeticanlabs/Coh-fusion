# Build Scope

**STATUS: canonical** (see `build_status.md` for detailed file inventory)

## Purpose

This document describes what the canonical build includes, what it excludes, and why.

---

## Canonical Build Scope

### Included Areas

1. **Core** — State, Receipt, Decision, CohObject class, Obligations
2. **Numeric** — QFixed arithmetic, Policy, Interval, BoundsAxioms, Serialize
3. **Geometry** — VDE (core + runtime), Tearing (core + runtime), Composition, C-2C theorems
4. **Runtime** — VerifierSemantics (generic + QFixed), Bridge, HashBoundedReceipt
5. **Product** — HardwareCertificate, CommercialWedge
6. **Schema** — Frames, Adapters
7. **Crypto** — Digest, Serialize, Ledger (excluding dev stub)

### Theorem Layer (Rational Shadow)

- **C-4B** — DissipativeDescent (kernel + VDE specialization + Tearing specialization)
- **C-2C** — Transversality measure for geometry layer

These operate over ℚ (rational numbers) and provide the mathematical foundation. The bridge to executable code uses QFixed.

---

## Excluded Areas

### Draft Files

These files contain useful work but are incomplete, unstable, or not yet trusted:

| File | Reason |
|------|--------|
| `src/CohFusion/Continuum/Observables.lean` | PDE lift placeholder - abstract signatures only |
| `src/CohFusion/Continuum/LiftedSet.lean` | PDE lift placeholder - abstract signatures only |
| `src/CohFusion/Continuum/OplaxProjection.lean` | PDE lift placeholder - abstract signatures only |
| `src/CohFusion/Control/VDE_Quadratic.lean` | Theorem pending formal proof |

### Excluded Files

| File | Reason |
|------|--------|
| `src/CohFusion/Crypto/DigestStub.lean` | Dev-only stub, not for production |

---

## Why This Scope?

### Rationale for Inclusion

1. **QFixed** — Required for deterministic runtime evaluation (not IEEE-754 Float)
2. **VerifierSemantics** — The core RV kernel that validates receipts
3. **HardwareCertificate** — Required for physical device authorization
4. **Geometry (VDE/Tearing)** — The two primary failure modes we must control

### Rationale for Exclusion

1. **Continuum files** — These are placeholder abstractions for PDE-to-discrete lift. They represent intended architecture but lack formal justification. They are not needed for the immediate verifier wedge.

2. **VDE_Quadratic theorem** — The `synthesized_control_contracts` proof is pending. While the control synthesis logic is sound, the formal proof requires substantial work. Per Phase 1 rules: "either complete it, or downgrade that file from canonical to draft."

---

## Build Truth

- **Canonical files:** No `sorry`, no unresolved identifiers, no stale imports
- **Draft files:** Marked as incomplete, not part of the canonical build path
- **Excluded files:** Explicitly not for production use

---

## Notes

- The theorem layer (C-4B, C-2C) operates over ℚ (rational numbers) as "rational shadow" models
- The executable runtime uses QFixed (fixed-point arithmetic)
- The bridge between theorem and runtime is intentionally narrow

---

*Last updated: 2026-03-29*