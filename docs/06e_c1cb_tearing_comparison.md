# C-1C(b): Physical Tearing Comparison

## Overview

Theorem C-1C(b) compares the formal control algebra's tearing mode predictions against physical tearing modes in the continuum layer.

## Formal Statement

**Theorem C-1C(b) (Tearing Comparison)**: The formal tearing index τ(c) computed in the control algebra agrees with the physical tearing mode growth rate γ_physical up to a bounded correction:

```math
|τ(c) - γ_physical| ≤ ε_tearing
```

For admissible controls c with bounded perturbation.

## Relationship to Continuum Physics

This theorem bridges:
- **Algebraic side**: Formal τ(c) from R₄ categorical structure
- **Physical side**: Measured/dynamo-calculated γ_physical

The bounded correction ε_tearing accounts for:
- Simplified geometry assumptions
- Neglected higher-order terms
- Numerical discretization effects

## Status

- **Specification**: Complete
- **Mechanization**: Not started
- **Priority**: Medium

## Explicit Scope Limitation

**This is NOT a proof that plasma physics is complete.** The theorem explicitly:
- Acknowledges the ε_tearing gap
- Does not claim to prove plasma stability
- Documents the correction bound

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md) — Out of scope note
- [`docs/appendices/C_gap_ledger.md`](appendices/C_gap_ledger.md)