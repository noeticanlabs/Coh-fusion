import CohFusion.Control.Theorems.C4B_DissipativeDescent
import CohFusion.Control.VDE_Abstract
import CohFusion.Control.VDE_Quadratic
import CohFusion.Geometry.VDECore
import CohFusion.Numeric.QFixed

/-!
# C-4B VDE Specialization: Dissipative Descent for VDE Control

This file specializes the generic C-4B kernel theorem to the VDE (Vertically-Distorted
Element) control system. It provides the concrete binding between:

- The abstract `ControlParams` structure
- The VDE state and parameter types
- The quadratic control synthesis (`synthesizeQuadratic`)
- The Lyapunov function (`VgeomVDE`)

## Key Theorems

1. `vde_defect_dominates_spend_implies_strict_descent` - one-step descent
2. `vde_coercive_spend_implies_geometric_contraction` - geometric bound
3. `vde_telescoping_dissipative_bound` - multi-step receipt

## Concrete Type Mapping

The specialization maps:
- `State` → `VDE.StateVDE QFixed`
- `Control` → `QFixed` (scalar control input)
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
## VDE Control Parameters as ControlParams

We instantiate the generic `ControlParams` with VDE-specific types and functions.
-/

/-- VDE disturbance: pair of Z and I_act disturbances. -/
structure VDE_Disturbance (α : Type) where
  d_Z  : α
  d_I  : α

/-- Convert VDE params + gains to generic ControlParams. -/
def vdeControlParams
    (p : CohFusion.Geometry.VDE.Params QFixed)
    (g : VDE_Quadratic.VDEControlGains QFixed)
    (dt : QFixed) :
    ControlParams
      (CohFusion.Geometry.VDE.StateVDE QFixed)
      QFixed
      (VDE_Disturbance QFixed) :=
  { step := λ x u d =>
      VDE_Abstract.vdeStep p x dt u d.d_Z d.d_I,
    kappa := λ x => VDE_Quadratic.synthesizeQuadratic g x,
    V := λ s => VgeomVDE p s,
    spend := λ s u => u * u * dt,
    defect := λ s d => d.d_Z * d.d_Z + d.d_I * d.d_I  -- squared disturbance norm
    }

/-!
## C-4B VDE Theorem: Strict Descent Under Defect Dominance

This is the concrete VDE instance of the generic kernel theorem.
The spend is `u*u*dt` and the defect is the squared disturbance norm.
-/

theorem vde_defect_dominates_spend_implies_strict_descent
    (p : CohFusion.Geometry.VDE.Params QFixed)
    (g : VDE_Quadratic.VDEControlGains QFixed)
    (dt : QFixed)
    (η : QFixed)
    (s : CohFusion.Geometry.VDE.StateVDE QFixed)
    (d : VDE_Disturbance QFixed)
    (hdesc : VDE_Abstract.ControllerDescent p dt (d.d_Z * d.d_Z + d.d_I * d.d_I)
                s (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I)
                (VDE_Quadratic.synthesizeQuadratic g s))
    (hdom : d.d_Z * d.d_Z + d.d_I * d.d_I ≤ η * (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt) :
    VgeomVDE p (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I)
      ≤ VgeomVDE p s - (1 - η) * (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt :=
begin
  -- Construct the ControlParams instance
  let cp := vdeControlParams p g dt,

  -- The generic theorem requires OplaxDescent and DefectDominated
  -- We need to show these match the VDE definitions

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
## C-4B VDE Corollary: Geometric Contraction

If the control authority satisfies a coercivity bound, we get geometric contraction.
-/

theorem vde_coercive_spend_implies_geometric_contraction
    (p : CohFusion.Geometry.VDE.Params QFixed)
    (g : VDE_Quadratic.VDEControlGains QFixed)
    (dt η c : QFixed)
    (s : CohFusion.Geometry.VDE.StateVDE QFixed)
    (d : VDE_Disturbance QFixed)
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
## C-4B VDE Multi-Step: Telescoping Receipt

For a trajectory of n steps, the Lyapunov values telescope with the discounted spends.
-/

/-- VDE trajectory: apply VDE step repeatedly. -/
def vdeTrajectory
    (p : CohFusion.Geometry.VDE.Params QFixed)
    (g : VDE_Quadratic.VDEControlGains QFixed)
    (dt : QFixed)
    (s : CohFusion.Geometry.VDE.StateVDE QFixed)
    (ds : List (VDE_Disturbance QFixed)) :
    CohFusion.Geometry.VDE.StateVDE QFixed :=
  match ds with
  | []      => s
  | d :: ds => vdeTrajectory p g dt
      (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I) ds

/-- VDE discounted spend sum. -/
def vdeDiscountedSpendSum
    (p : CohFusion.Geometry.VDE.Params QFixed)
    (g : VDE_Quadratic.VDEControlGains QFixed)
    (dt η : QFixed)
    (s : CohFusion.Geometry.VDE.StateVDE QFixed)
    (ds : List (VDE_Disturbance QFixed)) : QFixed :=
  match ds with
  | []      => 0
  | d :: ds =>
      (1 - η) * (VDE_Quadratic.synthesizeQuadratic g s)^2 * dt
      + vdeDiscountedSpendSum p g dt η
        (VDE_Abstract.vdeStep p s dt (VDE_Quadratic.synthesizeQuadratic g s) d.d_Z d.d_I) ds

/-- VDE telescoping receipt theorem. -/
theorem vde_telescoping_dissipative_bound
    (p : CohFusion.Geometry.VDE.Params QFixed)
    (g : VDE_Quadratic.VDEControlGains QFixed)
    (dt η : QFixed)
    (s : CohFusion.Geometry.VDE.StateVDE QFixed)
    (ds : List (VDE_Disturbance QFixed))
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
