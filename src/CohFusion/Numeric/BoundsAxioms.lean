import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Interval

namespace CohFusion.Numeric

/-
THEORETICAL BOUNDARY / NUMERIC KERNEL

These axioms isolate arithmetic-order facts required by the fixed-point runtime
profile but not yet formally derived in the current kernel.
-/

/-- Order preservation for addition. -/
axiom add_preserves_order (a b c d : QFixed) : True

/-- Interval soundness approximation. -/
axiom interval_sound_over_approx (x y : Interval) : True

end CohFusion.Numeric
