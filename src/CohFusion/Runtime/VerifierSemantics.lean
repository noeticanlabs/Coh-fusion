import CohFusion.Core.Receipt
import CohFusion.Core.Decision

namespace CohFusion.Runtime

/-- Pure total verifier semantics for runtime validation. -/

/-- Verifier checks a micro-receipt and returns a decision. -/
def verifyMicroReceipt
    (validate : Core.MicroReceipt α → Bool)
    (r : Core.MicroReceipt α) : Core.Decision :=
  if validate r then Core.Decision.accept
  else Core.Decision.reject Core.RejectCode.defectOutOfBounds

/-- Micro-receipt soundness: receipt is well-formed. -/
def microReceiptSound (r : Core.MicroReceipt α) : Prop :=
  r.spendAuth ≥ 0 ∧ r.defectDeclared ≥ 0

/-- Slab telescoping: trace accumulates correctly. -/
def slabTelescoping (trace : List (Core.MicroReceipt α)) : Prop :=
  List.Forall₂ (fun r1 r2 => r1.stateNext = r2.statePrev) trace

end CohFusion.Runtime
