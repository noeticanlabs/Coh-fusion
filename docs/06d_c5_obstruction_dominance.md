# C-5: Obstruction Dominance

## Overview

Theorem C-5 establishes that control obstructions are dominated by the structural constraints of the R₄ categorical layer, ensuring that any "impossible" control states are correctly identified.

## Formal Statement

**Theorem C-5 (Obstruction Dominance)**: For any putative control c ∉ C, there exists a morphism f: R₄ → Obstruction(c) that witnesses the obstruction:

```math
∃ f: R₄ → Obstruction(c) ⟹ c is not admissible
```

## Obstruction Categories

1. **Algebraic obstructions**: Violations of R₂ composition laws
2. **Stability obstructions**: Violations of R₃ stability predicate
3. **Geometric obstructions**: Non-transverse to boundary
4. **Numeric obstructions**: Overflow/underflow in QFixed representation

## Status

- **Specification**: Complete
- **Mechanization**: Not started
- **Priority**: Medium

## Implementation Notes

The obstruction dominance check requires:
- Classification of obstruction types
- Witness morphism construction
- Decision procedure for admissibility

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md)
- [`docs/06b_c4b_theorem_target.md`](06b_c4b_theorem_target.md)