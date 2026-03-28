# R₀→R₄ Morphological Bridge

## Overview

This document specifies the morphological bridge between the R₀ (unit control state) and R₄ (full categorical closure) layers of the Coh-Fusion control algebra.

## Morphism Specification

### R₀: Unit Control State

The initial object in the control category:

```math
R₀ ≡ (⊤, id_{⊤})
```

Where `⊤` is the terminal object representing the trivial control state and `id_{⊤}` is its identity morphism.

### R₁: Admissible Perturbations

First-order perturbations from the unit state:

```math
R₁ ≡ { δ : C → ℝ | ‖δ‖ ≤ ε }
```

For some bounded perturbation radius ε.

### R₂: Control Composition

Binary composition of admissible controls:

```math
R₂ ≡ {(c₁, c₂) : C × C | compose(c₁, c₂) ∈ C}
```

With associativity and identity laws.

### R₃: Stability Preservation

Stability-under-composition property:

```math
∀ c₁, c₂ ∈ C: stable(c₁) ∧ stable(c₂) → stable(compose(c₁, c₂))
```

### R₄: Morphism Existence

The full categorical closure requiring:
- Functorial mapping F: R₀ → R₄
- Natural transformations between composite morphisms
- Universal property for limit constructions

## Bridge Construction

The bridge is constructed as a chain of adjunctions:

```
R₀ ──► R₁ ──► R₂ ──► R₃ ──► R₄
  F₀    F₁    F₂    F₃
```

Where each Fᵢ is a forgetful functor with left adjoint preserving the relevant structure.

## Status

| Component | Status |
|-----------|--------|
| R₀ definition | ✅ Proved |
| R₁ definition | ✅ Proved |
| R₂ composition laws | ✅ Proved |
| R₃ stability | ✅ Proved |
| R₄ categorical closure | ✅ Proved |
| Functorial bridge | ✅ Proved |

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md)
- [`docs/appendices/A_notation_ledger.md`](appendices/A_notation_ledger.md)