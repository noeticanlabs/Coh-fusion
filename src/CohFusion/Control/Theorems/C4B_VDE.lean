import Mathlib.Algebra.Ring.Rat
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import CohFusion.Control.Theorems.C4B_DissipativeDescent
import CohFusion.Control.VDE_Abstract
import CohFusion.Control.VDE_Quadratic
import CohFusion.Geometry.VDECore

/-!
# C-4B VDE Rational Shadow Specialization: Dissipative Descent for VDE Control

This file specializes the generic C-4B kernel theorem to the VDE (Vertically-Distorted
Element) control system using rational shadow models (α = ℚ).

## Scalar Choice

This file operates over the rational numbers ℚ for full algebraic tractability.
The VDE control system is defined polymorphically over any type with the appropriate
algebraic structure, so we can instantiate it with ℚ for the theorem layer.

## Key Theorems

1. `vde_defect_dominates_spend_implies_strict_descent` - one-step descent
2. `vde_coercive_spend_implies_geometric_contraction` - geometric bound
3. `vde_telescoping_dissipative_bound` - multi-step receipt

## Concrete Type Mapping (Rational Shadow)

The specialization maps:
- `State` → `VDE.StateVDE ℚ`
- `Control` → `ℚ` (scalar control input)
- `Disturbance` → `VDE_Disturbance` (d_Z, d_I pair)
- `V` → `VgeomVDE p`
- `spend` → `u*u*dt` (quadratic control effort)
- `defect` → `defect` parameter

## Usage Pattern

```lean
-- Show defect dominance: |d| ≤ η * |u| (with some margin)
have hdom := DefectDominated p η s d hdefectbound,

-- Show oplax descent: V(s⁺) ≤ V(s) - u*u*dt + defect
have hdesc := ControllerDescent p dt defect s sNext u,

-- Apply the theorem
exact vde_defect_dominates_spend_implies_strict_descent p η s d hdesc hdom
```
-/

namespace CohFusion.Control.Theorems

/-!
## VDE Control Parameters as ControlParams (Rational Shadow)

We instantiate the generic `ControlParams` with VDE-specific types and functions
over ℚ. This is a rational shadow model - the actual executable uses QFixed.
-/

/-- VDE disturbance: pair of Z and I_act disturbances. -/
structure VDE_Disturbance (α : Type) where
  d_Z  : α
  d_I  : α

/-- Convert VDE params + gains to generic ControlParams over ℚ. -/
def vdeControlParams
    (p : CohFusion.Geometry.VDE.Params ℚ)
    (g : VDE_Quadratic.VDEControlGains ℚ)
    (dt : ℚ) :
    ControlParams
      (CohFusion.Geometry.VDE.StateVDE ℚ)
      ℚ
      (VDE_Disturbance ℚ) :=
  { step := λ x u d =>
      VDE_Abstract.vdeStep p x dt u d.d_Z d.d_I,
    kappa := λ x => VDE_Quadratic.synthesizeQuadratic g x,
    V := λ s => VgeomVDE p s,
    spend := λ s u => u * u * dt,
    defect := λ s d => d.d_Z * d.d_Z + d.d_I * d.d_I  -- squared disturbance norm
    }

/-!
## C-4B VDE Theorem (Rational): Strict Descent Under Defect Dominance

This is the concrete VDE instance of the generic kernel theorem over ℚ.
The spend is `u*u*dt` and the defect is the squared disturbance norm.
-/

theorem vde_defect_dominates_spend_implies_strict_descent
    (p : CohFusion.Geometry.VDE.Params ℚ)
    (g : VDE_Quadratic.VDEControlGains ℚ)
    (dt : ℚ)
    (η : ℚ)
    (s : CohFusion.Geometry.VDE.StateVDE ℚ)
    (d : VDE_Disturbance ℚ)
    (hdesc : VDE_Abstract.ControllerDescent p dt (d.d_Z * d.d_Z + d.d_I * d.d_I)
                s (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I)
                (VDE_Quadratic.synthesizeQuadratic g s))
    (hdom : d.d_Z * d.d_Z + d.d_I * d.d_I ≤ η * (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt) :
    VgeomVDE p (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I)
      ≤ VgeomVDE p s - (1 - η) * (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt :=
begin
  -- Construct the ControlParams instance
  let cp := vdeControlParams p g dt,

  -- Unfold OplaxDescent for VDE:
  -- V(s⁺) ≤ V(s) - u*u*dt + defect
  -- This is exactly VDE_Abstract.ControllerDescent

  -- Unfold DefectDominated:
  -- defect ≤ η * spend
  -- d.d_Z² + d.d_I² ≤ η * u² * dt
  -- This is exactly hdom

  -- Apply the generic theorem
  exact defect_dominates_spend_implies_strict_descent cp η s d hdesc hdom
end

/-!
## C-4B VDE Corollary (Rational): Geometric Contraction

If the control authority satisfies a coercivity bound, we get geometric contraction.
-/

theorem vde_coercive_spend_implies_geometric_contraction
    (p : CohFusion.Geometry.VDE.Params ℚ)
    (g : VDE_Quadratic.VDEControlGains ℚ)
    (dt η c : ℚ)
    (s : CohFusion.Geometry.VDE.StateVDE ℚ)
    (d : VDE_Disturbance ℚ)
    (hdesc : VDE_Abstract.ControllerDescent p dt (d.d_Z * d.d_Z + d.d_I * d.d_I)
                s (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I)
                (VDE_Quadratic.synthesizeQuadratic g s))
    (hdom : d.d_Z * d.d_Z + d.d_I * d.d_I ≤ η * (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt)
    (hcoer : c * VgeomVDE p s ≤ (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt)
    (heta : 0 ≤ 1 - η) :
    VgeomVDE p (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I)
      ≤ (1 - c * (1 - η)) * VgeomVDE p s :=
begin
  let cp := vdeControlParams p g dt,
  exact coercive_spend_implies_geometric_contraction cp η c s d hdesc hdom hcoer heta
end

/-!
## C-4B VDE Multi-Step: Telescoping Receipt (Rational)

For a trajectory of n steps, the Lyapunov values telescope with the discounted spends.
-/

/-- VDE trajectory: apply VDE step repeatedly over ℚ. -/
def vdeTrajectory
    (p : CohFusion.Geometry.VDE.Params ℚ)
    (g : VDE_Quadratic.VDEControlGains ℚ)
    (dt : ℚ)
    (s : CohFusion.Geometry.VDE.StateVDE ℚ)
    (ds : List (VDE_Disturbance ℚ)) :
    CohFusion.Geometry.VDE.StateVDE ℚ :=
  match ds with
  | []      => s
  | d :: ds => vdeTrajectory p g dt
      (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I) ds

/-- VDE discounted spend sum over ℚ. -/
def vdeDiscountedSpendSum
    (p : CohFusion.Geometry.VDE.Params ℚ)
    (g : VDE_Quadratic.VDEControlGains ℚ)
    (dt η : ℚ)
    (s : CohFusion.Geometry.VDE.StateVDE ℚ)
    (ds : List (VDE_Disturbance ℚ)) : ℚ :=
  match ds with
  | []      => 0
  | d :: ds =>
      (1 - η) * (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt
      + vdeDiscountedSpendSum p g dt η
        (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I) ds

/-- VDE telescoping receipt theorem over ℚ. -/
theorem vde_telescoping_dissipative_bound
    (p : CohFusion.Geometry.VDE.Params ℚ)
    (g : VDE_Quadratic.VDEControlGains ℚ)
    (dt η : ℚ)
    (s : CohFusion.Geometry.VDE.StateVDE ℚ)
    (ds : List (VDE_Disturbance ℚ))
    (hstep : ∀ s d,
      let u := VDE_Quadratic.synthesizeQuadratic g s
      let sNext := VDE_Abstract.vdeStep p s dt u d.d_Z d.d_I
      let defect := d.d_Z * d.d_Z + d.d_I * d.d_I
      VDE_Abstract.ControllerDescent p dt defect s sNext u
      ∧ (defect ≤ η * u^2 * dt)) :
    VgeomVDE p (vdeTrajectory p g dt s ds) + vdeDiscountedSpendSum p g dt η s ds
      ≤ VgeomVDE p s :=
begin
  let cp := vdeControlParams p g dt,
  -- The generic telescoping theorem requires the step hypothesis
  -- which we've packaged in hstep
  exact telescoping_dissipative_bound cp η hstep s ds
end

end CohFusion.Control.Theorems
