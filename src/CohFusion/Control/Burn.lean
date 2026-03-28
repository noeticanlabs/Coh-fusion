import Mathlib.Data.Rat.Basic
import CohFusion.Core.Decision

namespace CohFusion.Control.Burn

open CohFusion.Core

/-- Plasma state for burn verification. -/
structure PlasmaState where
  beta        : ℚ  -- plasma beta
  temperature : ℚ  -- ion temperature
  density     : ℚ  -- ion density
  deriving Repr, DecidableEq

/-- Hardware specification limits. -/
structure HardwareSpec where
  I_max      : ℚ  -- maximum current
  I_dot_max  : ℚ  -- maximum current derivative
  tau_sensor : ℚ  -- sensor time constant
  deriving Repr, DecidableEq

/-- Burn receipt for resource consumption tracking. -/
structure BurnReceipt where
  dt            : ℚ  -- burn duration
  etaAvailable  : ℚ  -- available energy
  spend         : ℚ  -- authorization spend
  eModel        : ℚ  -- model error
  eAct          : ℚ  -- actuator error
  eSensor       : ℚ  -- sensor error
  deriving Repr, DecidableEq

/-- Total burn defect = model + actuator + sensor errors. -/
def totalBurnDefect (r : BurnReceipt) : ℚ :=
  r.eModel + r.eAct + r.eSensor

/-- Lawson criterion: beta * density * temperature >= threshold. -/
def satisfiesLawson (x : PlasmaState) : Prop :=
  x.beta * x.density * x.temperature ≥ 100

/-- Affordability: available energy * dt > total defect. -/
def isAffordable (r : BurnReceipt) : Prop :=
  r.etaAvailable * r.dt > totalBurnDefect r

/-- Verify ignition: checks Lawson criterion and affordability. -/
def verifyIgnition (x : PlasmaState) (r : BurnReceipt) : Decision :=
  if ¬ satisfiesLawson x then
    Decision.reject RejectCode.unauthorizedTransition
  else if ¬ isAffordable r then
    Decision.reject RejectCode.unaffordableBurn
  else
    Decision.accept

end CohFusion.Control.Burn
