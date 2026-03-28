import CohFusion.Core.Receipt
import CohFusion.Core.Decision

namespace CohFusion.Runtime

/-- Verifier checks a micro-receipt and returns a decision based on threshold, defect, and linkage. -/
def verifyMicroReceipt
    (validate : CohFusion.Core.MicroReceipt α → Bool)
    (r : CohFusion.Core.MicroReceipt α)
    (threshold : α)
    [LE α] [DecidableRel (fun (x y : α) => x ≥ y)] : CohFusion.Core.Decision :=
  if r.defectDeclared ≥ threshold then
    CohFusion.Core.Decision.reject CohFusion.Core.RejectCode.defectOutOfBounds
  else if ¬ validate r then
    CohFusion.Core.Decision.reject CohFusion.Core.RejectCode.defectOutOfBounds
  else
    CohFusion.Core.Decision.accept

/-- Micro-receipt soundness: receipt is well-formed. -/
def microReceiptSound [LE α] [OfNat α 0] (r : CohFusion.Core.MicroReceipt α) : Prop :=
  0 ≤ r.spendAuth ∧ 0 ≤ r.defectDeclared

/-- Adjacent linked: consecutive receipts have matching state (Oplax linkage). -/
def adjacentLinked : List (CohFusion.Core.MicroReceipt α) → Prop
  | [] => True
  | [_] => True
  | r1 :: r2 :: rs => r1.stateNext = r2.statePrev ∧ adjacentLinked (r2 :: rs)

end CohFusion.Runtime
