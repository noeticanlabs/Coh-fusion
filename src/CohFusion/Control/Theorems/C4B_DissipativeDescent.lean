import Mathlib.Algebra.Ring.Rat
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# C-4B: Dissipative Descent in the Control Algebra

This file provides the kernel theorem for closed-loop Lyapunov descent under
defect dominance. The theorem operates at the algebraic level using `ℚ` as the
base ordered field.

The key inequality is:
```
V(x⁺) ≤ V(x) - (1 - η) * spend(x)
```

where `η` is the defect dominance parameter (defect ≤ η * spend).

## File Structure

- This file: generic kernel theorem on `ℚ`
- `C4B_VDE.lean`: specialization to VDE with QFixed
- `C4B_Tearing.lean`: specialization to Tearing with QFixed
- `C4B_Composition.lean`: specialization to joint VDE+Tearing composition

## Proof Order

1. `defect_dominates_spend_implies_strict_descent` - one-step refined descent
2. `coercive_spend_implies_geometric_contraction` - geometric contraction bound
3. `telescoping_dissipative_bound` - multi-step receipt theorem
-/

namespace CohFusion.Control.Theorems

/-!
## Generic Control Parameters

These are defined at the algebraic level with `ℚ` coefficients.
Later specializations will map concrete types (VDE, Tearing) into this shape.
-/

/-- Control parameters: step function, controller, Lyapunov value, spend, defect. -/
structure ControlParams (State Control Disturbance : Type) where
  step   : State → Control → Disturbance → State
  kappa  : State → Control
  V      : State → ℚ
  spend  : State → Control → ℚ
  defect : State → Disturbance → ℚ

/-- Closed-loop one-step map: apply controller to state, then step with disturbance. -/
def closedLoopStep
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (x : State) (d : Disturbance) : State :=
  p.step x (p.kappa x) d

/--
Oplax descent inequality:
```
V(x⁺) ≤ V(x) - spend(x, κ(x)) + defect(x, d)
```
This is the standard one-step Lyapunov descent condition.
-/
def OplaxDescent
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (x : State) (d : Disturbance) : Prop :=
  p.V (closedLoopStep p x d)
    ≤ p.V x - p.spend x (p.kappa x) + p.defect x d

/--
Defect dominance: the defect is bounded by a fraction η of the spend.
This is the key inequality that enables strict descent.
```
defect(x, d) ≤ η * spend(x, κ(x))
```
-/
def DefectDominated
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (η : ℚ) (x : State) (d : Disturbance) : Prop :=
  p.defect x d ≤ η * p.spend x (p.kappa x)

/--
Spend coercivity: the spend is bounded below by a multiple of the value.
```
c * V(x) ≤ spend(x, κ(x))
```
This enables geometric contraction estimates.
-/
def SpendCoercive
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (c : ℚ) (x : State) : Prop :=
  c * p.V x ≤ p.spend x (p.kappa x)

/-!
## C-4B Kernel Theorem: Strict Dissipative Descent

This is the core algebraic result: under defect dominance, the oplax descent
refines to strict descent with coefficient (1 - η).
-/

theorem defect_dominates_spend_implies_strict_descent
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (η : ℚ) (x : State) (d : Disturbance)
    (hdesc : OplaxDescent p x d)
    (hdom : DefectDominated p η x d) :
    p.V (closedLoopStep p x d)
      ≤ p.V x - (1 - η) * p.spend x (p.kappa x) :=
begin
  -- Unfold the definitions
  unfold OplaxDescent at hdesc,
  unfold DefectDominated at hdom,

  -- Substitute defect dominance into oplax descent
  have h1 : p.V (closedLoopStep p x d)
      ≤ p.V x - p.spend x (p.kappa x) + η * p.spend x (p.kappa x),
  { exact le_trans hdesc (add_le_add_left hdom _) },

  -- Algebraic rearrangement: -1 + η = -(1 - η)
  have h2 : p.V x - p.spend x (p.kappa x) + η * p.spend x (p.kappa x)
      = p.V x - (1 - η) * p.spend x (p.kappa x),
  { ring },

  -- Apply the rearrangement
  simpa [h2] using h1
end

/-!
## C-4B Corollary: Geometric Contraction

If the spend is coercive (bounded below by a multiple of V), then we get
geometric contraction of the Lyapunov value.
-/

theorem coercive_spend_implies_geometric_contraction
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (η c : ℚ) (x : State) (d : Disturbance)
    (hdesc : OplaxDescent p x d)
    (hdom : DefectDominated p η x d)
    (hcoer : SpendCoercive p c x)
    (heta : 0 ≤ 1 - η) :
    p.V (closedLoopStep p x d)
      ≤ (1 - c * (1 - η)) * p.V x :=
begin
  -- First get the strict descent inequality
  have hsd :
      p.V (closedLoopStep p x d)
        ≤ p.V x - (1 - η) * p.spend x (p.kappa x),
  { exact defect_dominates_spend_implies_strict_descent p η x d hdesc hdom },

  -- Apply coercivity: c * V(x) ≤ spend(x, κ(x))
  -- Since (1 - η) ≥ 0, we can multiply the inequality
  have hmul :
      (1 - η) * (c * p.V x) ≤ (1 - η) * p.spend x (p.kappa x),
  { exact mul_le_mul_of_nonneg_left hcoer heta },

  -- Rearrange: V(x⁺) ≤ V(x) - (1 - η) * spend ≤ V(x) - (1 - η) * c * V(x)
  --           = (1 - c * (1 - η)) * V(x)
  calc p.V (closedLoopStep p x d)
    ≤ p.V x - (1 - η) * p.spend x (p.kappa x) := hsd
    ... ≤ p.V x - (1 - η) * (c * p.V x) := sub_le_sub_left hmul (p.V x)
    ... = (1 - c * (1 - η)) * p.V x := by ring
end

/-!
## C-4B Multi-Step: Telescoping Dissipative Bound

For a trajectory of length n, the sum of discounted spends telescopes with
the Lyapunov values, giving a receipt-style inequality.
-/

/-- Trajectory: apply closed-loop step repeatedly over a disturbance list. -/
def trajectory
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (x : State) (ds : List Disturbance) : State :=
  match ds with
  | []      => x
  | d :: ds => trajectory p (closedLoopStep p x d) ds

/-- Sum of discounted spends along a trajectory. -/
def discountedSpendSum
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (η : ℚ) (x : State) (ds : List Disturbance) : ℚ :=
  match ds with
  | []      => 0
  | d :: ds =>
      (1 - η) * p.spend x (p.kappa x)
      + discountedSpendSum p η (closedLoopStep p x d) ds

/-- Telescoping receipt theorem: V(x₀) ≥ V(x_n) + Σ (1-η)^k * spend. -/
theorem telescoping_dissipative_bound
    {State Control Disturbance : Type}
    (p : ControlParams State Control Disturbance)
    (η : ℚ)
    (hstep : ∀ x d, OplaxDescent p x d ∧ DefectDominated p η x d)
    (x : State) (ds : List Disturbance) :
    p.V (trajectory p x ds) + discountedSpendSum p η x ds ≤ p.V x :=
begin
  induction ds generalizing x with
  | nil =>
    simp only [trajectory, discountedSpendSum, zero_add],
    exact le_refl (p.V x)
  | cons d ds ih =>
    rcases hstep x d with ⟨hdesc, hdom⟩,
    have hlocal :=
      defect_dominates_spend_implies_strict_descent p η x d hdesc hdom,
    have hind := ih (closedLoopStep p x d),
    calc p.V (trajectory p x (d :: ds))
        = p.V (trajectory p (closedLoopStep p x d) ds) := rfl
      ... ≤ p.V (closedLoopStep p x d)
          - (1 - η) * p.spend x (p.kappa x)
          + discountedSpendSum p η (closedLoopStep p x d) ds
        := by
          have := hind,
          linarith
      ... = p.V (closedLoopStep p x d)
          + discountedSpendSum p η x (d :: ds)
          - (1 - η) * p.spend x (p.kappa x)
        := by simp [discountedSpendSum]
      ... ≤ p.V x
        := by
          have := hlocal,
          linarith
end

end CohFusion.Control.Theorems
