# C-4B: Theorem Target

## Statement

**Theorem C-4B (Dissipation Stability)**: Under bounded dissipation operators, the control algebra R₄ preserves stability guarantees.

## Formal Statement

Given a dissipation operator D: C → C with bounded spectral radius ρ(D) ≤ λ < 1, the composed control c̄ = D ∘ c preserves the stability predicate:

```math
stable(c) → stable(D ∘ c)
```

## Proof Strategy

1. **Spectral bound lemma**: Show ρ(D) < 1 implies ‖D‖ < 1 in the control norm
2. **Composition stability**: Apply R₃ stability preservation
3. **Induction**: Extend to iterated dissipation sequences

## Current Status

- **Specification**: Complete
- **Mechanization**: Not started
- **Priority**: High

## Dependencies

- R₃ stability preservation (must be mechanized first)
- Numeric bounds from [`src/CohFusion/Numeric/QFixed.lean`](src/CohFusion/Numeric/QFixed.lean)

## Gap Notes

The proof requires:
- Formalization of spectral radius bounds in Lean
- Continuity of dissipation operator
- Induction framework for sequential composition

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md) — Theorem target tracking
- [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) — R₄ layer