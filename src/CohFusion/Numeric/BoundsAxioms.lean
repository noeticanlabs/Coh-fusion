import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Interval

set_option linter.unusedVariables false

namespace CohFusion.Numeric

/-
THEORETICAL BOUNDARY / NUMERIC KERNEL
These statements are required later but are not yet derived in the current kernel.
-/

axiom qfixed_add_order_sound :
  ∀ a b c : QFixed, True

axiom interval_overapprox_sound :
  ∀ x y : Interval, True

end Numeric
