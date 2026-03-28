namespace CohFusion.Core

/-- Flat verifier-visible fusion state. -/
structure State6 (α : Type) where
  Z     : α   -- vertical displacement observable
  vZ    : α   -- vertical velocity observable
  I_act : α   -- active vertical-control actuator state
  W     : α   -- regularized tearing-width proxy
  vW    : α   -- tearing growth-rate proxy
  I_cd  : α   -- current-drive actuator state
  deriving Repr, DecidableEq

end CohFusion.Core
