import CohFusion.Core.Decision

set_option linter.unusedVariables false

namespace CohFusion.Control.Burn

open CohFusion.Core

/-- Stub for Rational type until Mathlib is integrated. -/
structure Rat where
  val : Int
  deriving Repr, DecidableEq

instance : Add Rat := ⟨fun a b => ⟨a.val + b.val⟩⟩
instance : Mul Rat := ⟨fun a b => ⟨a.val * b.val⟩⟩
instance : LE Rat := ⟨fun a b => a.val ≤ b.val⟩
instance : LT Rat := ⟨fun a b => a.val < b.val⟩
instance : OfNat Rat n := ⟨⟨n⟩⟩

/-- Plasma state for burn verification. -/
structure PlasmaState where
  beta        : Rat
  temperature : Rat
  density     : Rat
  deriving Repr, DecidableEq

/-- Hardware specification limits. -/
structure HardwareSpec where
  I_max      : Rat
  I_dot_max  : Rat
  tau_sensor : Rat
  deriving Repr, DecidableEq

/-- Burn receipt for resource consumption tracking. -/
structure BurnReceipt where
  dt            : Rat
  etaAvailable  : Rat
  spend         : Rat
  eModel        : Rat
  eAct          : Rat
  eSensor       : Rat
  deriving Repr, DecidableEq

/-- Total burn defect = model + actuator + sensor errors. -/
def totalBurnDefect (r : BurnReceipt) : Rat :=
  r.eModel + r.eAct + r.eSensor

/-- Lawson criterion: beta * density * temperature >= threshold. -/
def satisfiesLawson (x : PlasmaState) : Prop :=
  x.beta * x.density * x.temperature ≥ 100

instance (x : PlasmaState) : Decidable (satisfiesLawson x) :=
  inferInstanceAs (Decidable (x.beta.val * x.density.val * x.temperature.val ≥ 100))

/-- Affordability: available energy * dt > total defect. -/
def isAffordable (r : BurnReceipt) : Prop :=
  r.etaAvailable * r.dt > totalBurnDefect r

instance (r : BurnReceipt) : Decidable (isAffordable r) :=
  inferInstanceAs (Decidable (r.etaAvailable.val * r.dt.val > (totalBurnDefect r).val))

/-- Verify ignition: checks Lawson criterion and affordability. -/
def verifyIgnition (x : PlasmaState) (r : BurnReceipt) : Decision :=
  if h : satisfiesLawson x then
    if h' : isAffordable r then
      Decision.accept
    else
      Decision.reject RejectCode.unaffordableBurn
  else
    Decision.reject RejectCode.unauthorizedTransition

end CohFusion.Control.Burn
