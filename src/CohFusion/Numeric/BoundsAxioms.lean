import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Interval

set_option linter.unusedVariables false

namespace CohFusion.Numeric

/--
  Evaluates if a QFixed value falls within a given interval.
  Used for grounding the theoretical bounds in concrete arithmetic.
-/
def QFixed.inInterval (q : QFixed) (i : Interval) : Bool :=
  i.lo ≤ q && q ≤ i.hi

/--
  Concrete evaluation of the discretization defect bound.
  In Step 3, we'll use this to bound E_disc.
-/
def checkDiscretizationBound (defect : QFixed) (bound : QFixed) : Bool :=
  defect ≤ bound

end CohFusion.Numeric
