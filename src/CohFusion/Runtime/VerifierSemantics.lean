import CohFusion.Core.Receipt
import CohFusion.Core.Decision

namespace CohFusion.Runtime

/-- Pure total verifier semantics for runtime validation. -/
def verifyMicroReceipt
    (validate : Core.MicroReceipt α → Bool)
    (r : Core.MicroReceipt α) : Core.Decision :=
  if validate r then Core.Decision.accept
  else Core.Decision.reject Core.RejectCode.defectOutOfBounds

/-- Micro-receipt soundness: receipt is well-formed. -/
def microReceiptSound [LE α] [OfNat α 0] (r : Core.MicroReceipt α) : Prop :=
  0 ≤ r.spendAuth ∧ 0 ≤ r.defectDeclared

/-- Adjacent linked: consecutive receipts have matching state. -/
def adjacentLinked : List (Core.MicroReceipt α) → Prop
  | [] => True
  | [_] => True
  | r1 :: r2 :: rs => r1.stateNext = r2.statePrev ∧ adjacentLinked (r2 :: rs)

end CohFusion.Runtime
