# Phase 2: Structural Normalization and Implementation Refinement

This plan outlines the steps to move the `gmiv2` repository from a scaffolded state to a coherent theorem skeleton.

## 1. Dependency and Core Math
- [ ] Update `lakefile.lean` to require `Mathlib`.
- [ ] Update `src/CohFusion/Control/Burn.lean` to use `Mathlib.Data.Rat.Basic`.
- [ ] Remove local `Rat` structure and manual instances in `Burn.lean`.

## 2. Namespace Hygiene
- [ ] Update `src/CohFusion/Runtime/VerifierSemantics.lean` with fully qualified names.
- [ ] Update `src/CohFusion/Runtime/HashBoundedReceipt.lean` with fully qualified names.
- [ ] Update `src/CohFusion/Runtime/Bridge.lean` with fully qualified names.

## 3. Geometry Enrichment
- [ ] **VDE**: Define `VgeomVDE` and `DisruptedVDE`.
- [ ] **Tearing**: Define `VgeomTear` and `DisruptedTear`.
- [ ] **Composition**: Define `VgeomFus` and `DisruptedFus`.

## 4. Control-Geometry Docking
- [ ] Refactor `VDE_Abstract.lean` to use `Geometry.VDE` types.
- [ ] Refactor `VDE_Quadratic.lean` to use `Geometry.VDE` types.
- [ ] Refactor `Tearing_Quadratic.lean` to use `Geometry.Tearing` types.
- [ ] Refactor `Control/Composition.lean` to use `Geometry.Composition` types.

## 5. Verifier Refinement
- [ ] Update `VerifierSemantics.lean` with threshold, defect, and oplax gates.

## 6. Root Cleanup
- [ ] Resolve duplication between `CohFusion.lean` and `src/CohFusion.lean`.
