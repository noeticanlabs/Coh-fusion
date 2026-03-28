# Appendix A: Notation Ledger

## Control Algebra Notation

| Symbol | Meaning | Defined In |
|--------|---------|------------|
| R₀ | Unit control state (terminal object) | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| R₁ | Admissible perturbations | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| R₂ | Control composition | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| R₃ | Stability preservation | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| R₄ | Full categorical closure | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| C | Control category/space | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| compose(c₁, c₂) | Composition operation | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| stable(c) | Stability predicate | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| ρ(D) | Spectral radius of operator D | [`docs/06b_c4b_theorem_target.md`](06b_c4b_theorem_target.md) |
| τ(c) | Formal tearing index | [`docs/06e_c1cb_tearing_comparison.md`](06e_c1cb_tearing_comparison.md) |
| γ_physical | Physical tearing mode growth rate | [`docs/06e_c1cb_tearing_comparison.md`](06e_c1cb_tearing_comparison.md) |
| ε_tearing | Tearing comparison bound | [`docs/06e_c1cb_tearing_comparison.md`](06e_c1cb_tearing_comparison.md) |

## Geometric Notation

| Symbol | Meaning | Defined In |
|--------|---------|------------|
| M | Tokamak phase space manifold | [`docs/06c_c2c_transversality_track.md`](06c_c2c_transversality_track.md) |
| ∂M | Plasma boundary manifold | [`docs/06c_c2c_transversality_track.md`](06c_c2c_transversality_track.md) |
| π_boundary | Boundary projection map | [`docs/06c_c2c_transversality_track.md`](06c_c2c_transversality_track.md) |
| TM | Tangent bundle of M | [`docs/06c_c2c_transversality_track.md`](06c_c2c_transversality_track.md) |

## Numeric Notation

| Symbol | Meaning | Defined In |
|--------|---------|------------|
| QFixed | Fixed-point numeric type | [`src/CohFusion/Numeric/QFixed.lean`](src/CohFusion/Numeric/QFixed.lean) |
| ε | Perturbation bound | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |
| ‖δ‖ | Norm of perturbation | [`docs/06a_r0_r4_morphological_bridge.md`](06a_r0_r4_morphological_bridge.md) |

## Theorem Labels

| Label | Theorem | Document |
|-------|---------|----------|
| C-4B | Dissipation Stability | [`docs/06b_c4b_theorem_target.md`](06b_c4b_theorem_target.md) |
| C-2C | Transversality Measure | [`docs/06c_c2c_transversality_track.md`](06c_c2c_transversality_track.md) |
| C-5 | Obstruction Dominance | [`docs/06d_c5_obstruction_dominance.md`](06d_c5_obstruction_dominance.md) |
| C-1C(b) | Tearing Comparison | [`docs/06e_c1cb_tearing_comparison.md`](06e_c1cb_tearing_comparison.md) |

## Acronyms

| Acronym | Full Form |
|---------|-----------|
| FUS-1 | Fusion Affordability Standard 1 |
| PDE | Partial Differential Equation |
| QFixed | Quantized Fixed-point number |
| R₀–R₄ | Control algebra layers 0-4 |