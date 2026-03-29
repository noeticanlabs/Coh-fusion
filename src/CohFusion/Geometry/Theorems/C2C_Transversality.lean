import Mathlib.Algebra.Ring.Rat
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import CohFusion.Geometry.VDECore
import CohFusion.Geometry.TearingCore

/-!
# C-2C: Transversality Measure in the Geometry Layer

This file provides the kernel theorem for quantitative transversality: a lower
gradient bound at the threshold surface implies nondegeneracy (nonzero normal).

## Scalar Choice

This file operates over the rational numbers ℚ for full algebraic tractability.
The VDE/Tearing specializations bind to rational shadow models of the physics,
which can later be lifted to QFixed for executable deployment.

## File Structure

- This file: generic transversality kernel over ℚ
- `C2C_VDEBoundary.lean`: VDE rational shadow specialization
- `C2C_TearingBoundary.lean`: Tearing rational shadow specialization

## Key Theorem

If the observable functional O(x) = Θ at the boundary and ||∇O(x)||² ≥ τ² > 0,
then ∇O(x) ≠ 0, i.e., the boundary is nondegenerate/transversal.

## Proof Order

1. `transversality_lower_bound_implies_nonzero_gradient` - core lemma
2. `vde_boundary_nondegenerate` - VDE rational specialization
3. `tearing_boundary_nondegenerate` - Tearing rational specialization
-/

namespace CohFusion.Geometry.Theorems

/-!
## Observable Geometry Structure

This defines the observable functional on the VDE/Tearing state space,
its gradient, and the threshold value. Defined over ℚ for algebraic closure.
-/

/-- Observable geometry: maps state to a scalar observable with threshold. -/
structure ObservableGeom (State : Type) where
  obs    : State → ℚ
  grad   : State → ℚ × ℚ
  thresh : ℚ

/-- Active boundary: states where the observable equals the threshold. -/
def OnBoundary {State : Type} (g : ObservableGeom State) (x : State) : Prop :=
  g.obs x = g.thresh

/-- Transversal measure: squared norm of the gradient at a point. -/
def TransversalMeasure {State : Type} (g : ObservableGeom State) (x : State) : ℚ :=
  let gx := g.grad x
  gx.1 * gx.1 + gx.2 * gx.2

/-- Quantitative transversality: boundary point with gradient norm lower bound. -/
def QuantitativeTransversal {State : Type}
    (g : ObservableGeom State) (τ : ℚ) (x : State) : Prop :=
  OnBoundary g x ∧ τ * τ ≤ TransversalMeasure g x

/-!
## C-2C Kernel Theorem: Lower Gradient Bound Implies Nonzero Gradient

This is the core algebraic result: if we have a quantitative lower bound on
the gradient norm at a boundary point, the gradient cannot be zero.
-/

theorem transversality_lower_bound_implies_nonzero_gradient
    {State : Type}
    (g : ObservableGeom State)
    (τ : ℚ)
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
    simp [hzero] },
  -- But we have τ² ≤ ||grad||², contradiction since τ > 0
  have hpos : 0 < τ * τ,
  { exact mul_pos hτ hτ },
  have : τ * τ ≤ 0 := by simpa [hnormzero],
  linarith
end

/-!
## C-2C VDE Rational Shadow Specialization: Threshold Boundary

For the VDE, the observable is VgeomVDE: the quadratic risk functional.
The threshold is Theta_V (the public safety envelope bound).

This uses rational shadow parameters (α = ℚ) for full theorem tractability.
-/

/-- VDE observable geometry over ℚ: VgeomVDE with its gradient and threshold. -/
def VDEObservableGeom (p : VDE.Params ℚ) : ObservableGeom (VDE.StateVDE ℚ) :=
  { obs := VgeomVDE p,
    grad := λ s => (2 * p.omega1 * s.Z, 2 * p.omega2 * s.vZ),
    thresh := p.Theta_V }

-- Note: The gradient uses 2D projection (Z, vZ) for simplicity.
-- The full 3D version would include I_act as well.

/-- VDE boundary over ℚ: states at the threshold. -/
def VDEBoundary (p : VDE.Params ℚ) (s : VDE.StateVDE ℚ) : Prop :=
  VgeomVDE p s = p.Theta_V

/-- VDE gradient norm squared over ℚ. -/
def VDEGradientNormSq (p : VDE.Params ℚ) (s : VDE.StateVDE ℚ) : ℚ :=
  let g := VDEObservableGeom p
  (2 * p.omega1 * s.Z)^2 + (2 * p.omega2 * s.vZ)^2

/-- C-2C for VDE over ℚ: boundary point with positive gradient measure is nondegenerate. -/
theorem vde_boundary_nondegenerate
    (p : VDE.Params ℚ)
    (τ : ℚ)
    (s : VDE.StateVDE ℚ)
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
## C-2C Tearing Rational Shadow Specialization: Threshold Boundary

For Tearing mode, the observable is VgeomTear: the tearing risk functional.
The threshold is Theta_T.

This uses rational shadow parameters (α = ℚ) for full theorem tractability.
-/

/-- Tearing observable geometry over ℚ: VgeomTear with its gradient and threshold. -/
def TearObservableGeom (p : Tear.Params ℚ) : ObservableGeom (Tear.StateTear ℚ) :=
  { obs := VgeomTear p,
    grad := λ s => (2 * p.nu1 * s.W, 2 * p.nu2 * s.vW),
    thresh := p.Theta_T }

-- Note: The gradient uses 2D projection (W, vW) for simplicity.
-- The full 3D version would include I_cd as well.

/-- Tearing boundary over ℚ: states at the tearing threshold. -/
def TearBoundary (p : Tear.Params ℚ) (s : Tear.StateTear ℚ) : Prop :=
  VgeomTear p s = p.Theta_T

/-- Tearing gradient norm squared over ℚ. -/
def TearGradientNormSq (p : Tear.Params ℚ) (s : Tear.StateTear ℚ) : ℚ :=
  let g := TearObservableGeom p
  (2 * p.nu1 * s.W)^2 + (2 * p.nu2 * s.vW)^2

/-- C-2C for Tearing over ℚ: boundary point with positive gradient measure is nondegenerate. -/
theorem tearing_boundary_nondegenerate
    (p : Tear.Params ℚ)
    (τ : ℚ)
    (s : Tear.StateTear ℚ)
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
