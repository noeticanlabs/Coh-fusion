import Mathlib.Algebra.Ring.Rat
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import CohFusion.Control.Theorems.C4B_DissipativeDescent
import CohFusion.Control.Tearing_Quadratic
import CohFusion.Geometry.TearingCore

/-!
# C-4B Tearing Rational Shadow Specialization: Dissipative Descent for Tearing Control

This file specializes the generic C-4B kernel theorem to the Tearing mode
control system using rational shadow models (α = ℚ).

## Scalar Choice

This file operates over the rational numbers ℚ for full algebraic tractability.
The Tearing control system is defined polymorphically over any type with the appropriate
algebraic structure, so we can instantiate it with ℚ for the theorem layer.

## Key Theorems

1. `tear_defect_dominates_spend_implies_strict_descent` - one-step descent
2. `tear_coercive_spend_implies_geometric_contraction` - geometric bound

## Concrete Type Mapping (Rational Shadow)

The specialization maps:
- `State` → `Tear.StateTear ℚ`
- `Control` → `ℚ` (scalar control input - current drive)
- `Disturbance` → `Tearing_Disturbance` (d_W, d_I pair)
- `V` → `VgeomTear p`
- `spend` → `u*u*dt` (quadratic control effort)
- `defect` → `defect` parameter
-/

namespace CohFusion.Control.Theorems

/-!
## Tearing Control Parameters as ControlParams (Rational Shadow)

We instantiate the generic `ControlParams` with Tearing-specific types and functions
over ℚ. This is a rational shadow model - the actual executable uses QFixed.
-/

/-- Tearing disturbance: pair of W and I_cd disturbances. -/
structure Tearing_Disturbance (α : Type) where
  d_W  : α
  d_I  : α

/-- Convert Tearing params + gains to generic ControlParams over ℚ. -/
def tearControlParams
    (p : CohFusion.Geometry.Tearing.Params ℚ)
    (g : Tearing_Quadratic.TearControlGains ℚ)
    (dt : ℚ) :
    ControlParams
      (CohFusion.Geometry.Tearing.StateTear ℚ)
      ℚ
      (Tearing_Disturbance ℚ) :=
  { step := λ x u d =>
      Tearing_Quadratic.tearStep p x dt u d.d_W d.d_I,
    kappa := λ x => Tearing_Quadratic.synthesizeQuadratic g x,
    V := λ s => CohFusion.Geometry.Tearing.VgeomTear p s,
    spend := λ s u => u * u * dt,
    defect := λ s d => d.d_W * d.d_W + d.d_I * d.d_I  -- squared disturbance norm
    }

/-!
## C-4B Tearing Theorem (Rational): Strict Descent Under Defect Dominance

This is the concrete Tearing instance of the generic kernel theorem over ℚ.
The spend is `u*u*dt` and the defect is the squared disturbance norm.
-/

/-- Controller descent for tearing: V(s⁺) ≤ V(s) - u*u*dt + defect -/
def TearingControllerDescent
    (p : CohFusion.Geometry.Tearing.Params ℚ)
    (dt defect : ℚ)
    (s sNext : CohFusion.Geometry.Tearing.StateTear ℚ)
    (u : ℚ) : Prop :=
  CohFusion.Geometry.Tearing.VgeomTear p sNext ≤
    CohFusion.Geometry.Tearing.VgeomTear p s - u * u * dt + defect

theorem tear_defect_dominates_spend_implies_strict_descent
    (p : CohFusion.Geometry.Tearing.Params ℚ)
    (g : Tearing_Quadratic.TearControlGains ℚ)
    (dt : ℚ)
    (η : ℚ)
    (s : CohFusion.Geometry.Tearing.StateTear ℚ)
    (d : Tearing_Disturbance ℚ)
    (hdesc : TearingControllerDescent p dt (d.d_W * d.d_W + d.d_I * d.d_I)
                s (Tearing_Quadratic.tearStep p s dt (Tearing_Quadratic.synthesizeQuadratic g s) d.d_W d.d_I)
                (Tearing_Quadratic.synthesizeQuadratic g s))
    (hdom : d.d_W * d.d_W + d.d_I * d.d_I ≤ η * (Tearing_Quadratic.synthesizeQuadratic g s)^2 * dt) :
    CohFusion.Geometry.Tearing.VgeomTear p (Tearing_Quadratic.tearStep p s dt (Tearing_Quadratic.synthesizeQuadratic g s) d.d_W d.d_I)
      ≤ CohFusion.Geometry.Tearing.VgeomTear p s - (1 - η) * (Tearing_Quadratic.synthesizeQuadratic g s)^2 * dt :=
begin
  -- Construct the ControlParams instance
  let cp := tearControlParams p g dt,

  -- Unfold OplaxDescent for Tearing:
  -- V(s⁺) ≤ V(s) - u*u*dt + defect
  -- This is exactly TearingControllerDescent

  -- Unfold DefectDominated:
  -- defect ≤ η * spend
  -- d.d_W² + d.d_I² ≤ η * u² * dt
  -- This is exactly hdom

  -- Apply the generic theorem
  exact defect_dominates_spend_implies_strict_descent cp η s d hdesc hdom
end

/-!
## C-4B Tearing Corollary (Rational): Geometric Contraction

If the control authority satisfies a coercivity bound, we get geometric contraction.
-/

theorem tear_coercive_spend_implies_geometric_contraction
    (p : CohFusion.Geometry.Tearing.Params ℚ)
    (g : Tearing_Quadratic.TearControlGains ℚ)
    (dt η c : ℚ)
    (s : CohFusion.Geometry.Tearing.StateTear ℚ)
    (d : Tearing_Disturbance ℚ)
    (hdesc : TearingControllerDescent p dt (d.d_W * d.d_W + d.d_I * d.d_I)
                s (Tearing_Quadratic.tearStep p s dt (Tearing_Quadratic.synthesizeQuadratic g s) d.d_W d.d_I)
                (Tearing_Quadratic.synthesizeQuadratic g s))
    (hdom : d.d_W * d.d_W + d.d_I * d.d_I ≤ η * (Tearing_Quadratic.synthesizeQuadratic g s)^2 * dt)
    (hcoer : c * CohFusion.Geometry.Tearing.VgeomTear p s ≤ (Tearing_Quadratic.synthesizeQuadratic g s)^2 * dt)
    (heta : 0 ≤ 1 - η) :
    CohFusion.Geometry.Tearing.VgeomTear p (Tearing_Quadratic.tearStep p s dt (Tearing_Quadratic.synthesizeQuadratic g s) d.d_W d.d_I)
      ≤ (1 - c * (1 - η)) * CohFusion.Geometry.Tearing.VgeomTear p s :=
begin
  let cp := tearControlParams p g dt,
  exact coercive_spend_implies_geometric_contraction cp η c s d hdesc hdom hcoer heta
end

end CohFusion.Control.Theorems
