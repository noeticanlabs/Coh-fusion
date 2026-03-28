namespace CohFusion.Geometry.Tearing

/-- Tearing mode state for finite-dimensional geometry. -/
structure StateTear (α : Type) where
  W    : α   -- toroidal flux
  vW   : α   -- toroidal flux velocity
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

end CohFusion.Geometry.Tearing
