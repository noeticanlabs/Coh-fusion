namespace CohFusion.Geometry.Tearing

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
  W_crit  : α  -- critical flux threshold
  Theta_T : α  -- tearing threshold
  deriving Repr

/-- Geometric Tearing functional (Vgeom). -/
def VgeomTear [Add α] [Mul α] [HPow α Nat α] (p : Params α) (s : StateTear α) : α :=
  p.nu1 * s.W^2 + p.nu2 * s.vW^2 + p.nu3 * s.I_cd^2

/-- Disruption predicate: Tearing exceeds safe geometric threshold. -/
def DisruptedTear [LE α] (p : Params α) (s : StateTear α) [Add α] [Mul α] [HPow α Nat α] : Prop :=
  VgeomTear p s ≥ p.Theta_T

end CohFusion.Geometry.Tearing
