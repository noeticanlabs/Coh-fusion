import CohFusion.Geometry.VDE
import CohFusion.Geometry.Tearing

namespace CohFusion.Geometry

/-- Joint VDE + Tearing state for composition. -/
structure StateFus (α : Type) where
  vde  : VDE.StateVDE α
  tear : Tearing.StateTear α
  deriving Repr, DecidableEq

end CohFusion.Geometry
