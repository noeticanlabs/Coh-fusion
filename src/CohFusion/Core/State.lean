namespace CohFusion.Core

/-- Six-component plasma state vector. -/
structure State6 (α : Type) where
  Z     : α  -- plasma current centroid
  vZ    : α  -- plasma current velocity
  I_act : α  -- active current
  W     : α  -- toroidal flux
  vW    : α  -- toroidal flux velocity
  I_cd  : α  -- current drive
  deriving Repr, DecidableEq

end CohFusion.Core
