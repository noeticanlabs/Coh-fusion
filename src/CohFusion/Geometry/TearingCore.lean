import CohFusion.Numeric.QFixed

namespace CohFusion.Geometry.Tearing

open CohFusion.Numeric

/-- Tearing mode state for finite-dimensional geometry. -/
structure StateTear (α : Type) where
  W    : α   -- tearing width
  vW   : α   -- tearing growth rate
  I_cd : α   -- current drive
  deriving Repr, DecidableEq

/-- Tearing mode parameters. -/
structure Params (α : Type) where
  nu1     : α  -- first tearing coefficient
  nu2     : α  -- second tearing coefficient
  nu3     : α  -- third tearing coefficient
  W_crit  : α  -- critical flux threshold (physical disruption)
  Theta_T : α  -- tearing threshold for public safety envelope
  deriving Repr

/--
Public geometric tearing functional.
Unnormalized quadratic; thresholds are calibrated to this convention.
-/
def VgeomTear {α : Type} [Add α] [Mul α] [HPow α Nat α] (p : Params α) (s : StateTear α) : α :=
  p.nu1 * s.W^2 + p.nu2 * s.vW^2 + p.nu3 * s.I_cd^2

/--
Physical tearing disruption predicate:
critical-width exceedance encoded in squared form.
-/
def DisruptedTear {α : Type} [Add α] [Mul α] [HPow α Nat α] [LE α] (p : Params α) (s : StateTear α) : Prop :=
  s.W^2 ≥ p.W_crit^2

/-- Public risk safety predicate for the tearing wedge. -/
def SafeByRiskTear {α : Type} [Add α] [Mul α] [HPow α Nat α] [LE α] (p : Params α) (s : StateTear α) : Prop :=
  VgeomTear p s ≤ p.Theta_T

end CohFusion.Geometry.Tearing
