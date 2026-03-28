import Mathlib.Algebra.Ring.Rat
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import CohFusion.Geometry.VDECore
import CohFusion.Geometry.TearingCore
import CohFusion.Numeric.QFixed

/-!
# C-2C: Transversality Measure in the Geometry Layer

This file provides the kernel theorem for quantitative transversality: a lower
gradient bound at the threshold surface implies nondegeneracy (nonzero normal).

## File Structure

- This file: generic transversality kernel on StateVDE/StateTear
- `C2C_VDEBoundary.lean`: VDE threshold boundary specialization
- `C2C_TearingBoundary.lean`: Tearing threshold boundary specialization

## Key Theorem

If the observable functional O(x) = Θ at the boundary and ||∇O(x)||² ≥ τ² > 0,
then ∇O(x) ≠ 0, i.e., the boundary is nondegenerate/transversal.

## Proof Order

1. `transversality_lower_bound_implies_nonzero_gradient` - core lemma
2. `active_boundary_with_positive_measure_is_nondegenerate` - VDE specialization
3. `tearing_boundary_with_positive_measure_is_nondegenerate` - Tearing specialization
-/

namespace CohFusion.Geometry.Theorems

/-!
## Observable Geometry Structure

This defines the observable functional on the VDE/Tearing state space,
its gradient, and the threshold value.
-/

/-- Observable geometry: maps state to a scalar observable with threshold. -/
structure ObservableGeom (State : Type) where
  obs    : State → QFixed
  grad   : State → QFixed × QFixed
  thresh : QFixed

/-- Active boundary: states where the observable equals the threshold. -/
def OnBoundary {State : Type} (g : ObservableGeom State) (x : State) : Prop :=
  g.obs x = g.thresh

/-- Transversal measure: squared norm of the gradient at a point. -/
def TransversalMeasure {State : Type} (g : ObservableGeom State) (x : State) : QFixed :=
  let gx := g.grad x
  gx.1 * gx.1 + gx.2 * gx.2

/-- Quantitative transversality: boundary point with gradient norm lower bound. -/
def QuantitativeTransversal {State : Type}
    (g : ObservableGeom State) (τ : QFixed) (x : State) : Prop :=
  OnBoundary g x ∧ τ * τ ≤ TransversalMeasure g x

/-!
## C-2C Kernel Theorem: Lower Gradient Bound Implies Nonzero Gradient

This is the core algebraic result: if we have a quantitative lower bound on
the gradient norm at a boundary point, the gradient cannot be zero.
-/

theorem transversality_lower_bound_implies_nonzero_gradient
    {State : Type}
    (g : ObservableGeom State)
    (τ : QFixed)
    (x : State)
    (hτ : 0 < τ)
    (htrans : QuantitativeTransversal g τ x) :
    g.grad x ≠ (0, 0) :=
begin
  rcases htrans with ⟨hboundary, hmeasure⟩,
  intro hzero,
  -- If gradient is zero, its squared norm is zero
  have hnormzero : TransversalMeasure g x = 0,
  { unfold TransversalMeasure,
    simp [hzero, QFixed.zero, QFixed.mul] },
  -- But we have τ² ≤ ||grad||², contradiction since τ > 0
  have hpos : 0 < τ * τ,
  { have hτ2 := mul_self_pos τ hτ,
    exact hτ2 },
  have : τ * τ ≤ 0 := by simpa [hnormzero],
  linarith
end

/-!
## C-2C VDE Specialization: Threshold Boundary

For the VDE, the observable is VgeomVDE: the quadratic risk functional.
The threshold is Theta_V (the public safety envelope bound).
-/

/-- VDE observable geometry: VgeomVDE with its gradient and threshold. -/
def VDEObservableGeom (p : VDE.Params QFixed) : ObservableGeom (VDE.StateVDE QFixed) :=
  { obs := VgeomVDE p,
    grad := λ s => (2 * p.omega1 * s.Z, 2 * p.omega2 * s.vZ),  -- ∇V = (2ω₁Z, 2ω₂vZ, 2ω₃I)
    thresh := p.Theta_V }

-- Note: The gradient has 3 components for the 3D state (Z, vZ, I_act).
-- For simplicity in this kernel theorem, we use the 2D projection (Z, vZ).
-- The full 3D version would use (Z, vZ, I_act).

/-- VDE boundary: states at the threshold. -/
def VDEBoundary (p : VDE.Params QFixed) (s : VDE.StateVDE QFixed) : Prop :=
  VgeomVDE p s = p.Theta_V

/-- VDE gradient norm squared. -/
def VDEGradientNormSq (p : VDE.Params QFixed) (s : VDE.StateVDE QFixed) : QFixed :=
  let g := VDEObservableGeom p
  (2 * p.omega1 * s.Z)^2 + (2 * p.omega2 * s.vZ)^2

/-- C-2C for VDE: boundary point with positive gradient measure is nondegenerate. -/
theorem vde_boundary_nondegenerate
    (p : VDE.Params QFixed)
    (τ : QFixed)
    (s : VDE.StateVDE QFixed)
    (hτ : 0 < τ)
    (hboundary : VDEBoundary p s)
    (hmeasure : τ * τ ≤ VDEGradientNormSq p s) :
    (2 * p.omega1 * s.Z, 2 * p.omega2 * s.vZ) ≠ (0, 0) :=
begin
  have htrans : QuantitativeTransversal (VDEObservableGeom p) τ s,
  { exact ⟨hboundary, hmeasure⟩ },
  exact transversality_lower_bound_implies_nonzero_gradient (VDEObservableGeom p) τ s hτ htrans
end

/-!
## C-2C Tearing Specialization: Threshold Boundary

For Tearing mode, the observable is VgeomTear: the tearing risk functional.
The threshold is Theta_T.
-/

/-- Tearing observable geometry: VgeomTear with its gradient and threshold. -/
def TearObservableGeom (p : Tear.Params QFixed) : ObservableGeom (Tear.StateTear QFixed) :=
  { obs := VgeomTear p,
    grad := λ s => (2 * p.nu1 * s.W, 2 * p.nu2 * s.vW),  -- ∇V = (2ν₁W, 2ν₂vW, 2ν₃I_cd)
    thresh := p.Theta_T }

/-- Tearing boundary: states at the tearing threshold. -/
def TearBoundary (p : Tear.Params QFixed) (s : Tear.StateTear QFixed) : Prop :=
  VgeomTear p s = p.Theta_T

/-- Tearing gradient norm squared. -/
def TearGradientNormSq (p : Tear.Params QFixed) (s : Tear.StateTear QFixed) : QFixed :=
  let g := TearObservableGeom p
  (2 * p.nu1 * s.W)^2 + (2 * p.nu2 * s.vW)^2

/-- C-2C for Tearing: boundary point with positive gradient measure is nondegenerate. -/
theorem tearing_boundary_nondegenerate
    (p : Tear.Params QFixed)
    (τ : QFixed)
    (s : Tear.StateTear QFixed)
    (hτ : 0 < τ)
    (hboundary : TearBoundary p s)
    (hmeasure : τ * τ ≤ TearGradientNormSq p s) :
    (2 * p.nu1 * s.W, 2 * p.nu2 * s.vW) ≠ (0, 0) :=
begin
  have htrans : QuantitativeTransversal (TearObservableGeom p) τ s,
  { exact ⟨hboundary, hmeasure⟩ },
  exact transversality_lower_bound_implies_nonzero_gradient (TearObservableGeom p) τ s hτ htrans
end

end CohFusion.Geometry.Theorems
