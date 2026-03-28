import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Policy

namespace CohFusion.Numeric

/-- Closed interval over QFixed. -/
structure Interval where
  lo : QFixed
  hi : QFixed
  deriving Repr, DecidableEq

instance : ConsensusSafe Interval := ⟨⟩

end CohFusion.Numeric
