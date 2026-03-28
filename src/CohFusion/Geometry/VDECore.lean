import CohFusion.Numeric.QFixed

namespace CohFusion.Geometry.VDE

open CohFusion.Numeric

/-- VDE state for finite-dimensional wedge geometry. -/
structure StateVDE (α : Type) where
  Z     : α  -- vertical displacement
  vZ    : α  -- vertical velocity
  I_act : α  -- active current
  deriving Repr, DecidableEq

/-- VDE parameters for public geometric quarantine. -/
structure Params (α : Type) where
  omega1     : α  -- first frequency component
  omega2     : α  -- second frequency component
  omega3     : α  -- third frequency component
  Z_wall     : α  -- wall position
  delta_safe : α  -- safe delta margin
  Theta_V    : α  -- VDE threshold for public safety envelope
  deriving Repr

/--
Public geometric VDE risk functional.
Unnormalized quadratic; thresholds are calibrated to this convention.
-/
def VgeomVDE {α : Type} [Add α] [Mul α] [HPow α Nat α] (p : Params α) (s : StateVDE α) : α :=
  p.omega1 * s.Z^2 + p.omega2 * s.vZ^2 + p.omega3 * s.I_act^2

/--
Physical VDE disruption predicate:
wall-touch encoded algebraically as |Z| ≥ Z_wall - delta_safe,
rewritten in squared form.
-/
def DisruptedVDE {α : Type} [Add α] [Sub α] [Mul α] [HPow α Nat α] [LE α] (p : Params α) (s : StateVDE α) : Prop :=
  s.Z^2 ≥ (p.Z_wall - p.delta_safe)^2

/-- Public risk safety predicate for the VDE wedge. -/
def SafeByRiskVDE {α : Type} [Add α] [Mul α] [HPow α Nat α] [LE α] (p : Params α) (s : StateVDE α) : Prop :=
  VgeomVDE p s ≤ p.Theta_V

end CohFusion.Geometry.VDE
