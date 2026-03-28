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

/-- Geometric Tearing functional (Vgeom) - Public Risk Functional. -/
def VgeomTear [Add α] [Mul α] [HPow α Nat α] (p : Params α) (s : StateTear α) : α :=
  p.nu1 * s.W^2 + p.nu2 * s.vW^2 + p.nu3 * s.I_cd^2

/-- Disruption predicate: Physical critical-width event. -/
def DisruptedTear [LE α] (p : Params α) (s : StateTear α) : Prop :=
  s.W ≥ p.W_crit

end CohFusion.Geometry.Tearing
