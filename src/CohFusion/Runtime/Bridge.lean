import CohFusion.Core.Receipt
import CohFusion.Runtime.VerifierSemantics

namespace CohFusion.Runtime

/- Runtime bridge: connects low-level receipts to high-level verifier semantics. -/

/-- Bridge verifier: runs the verifier on a stream of receipts. -/
def bridgeVerifier
    [DecidableEq α]
    (validate : CohFusion.Core.MicroReceipt α → Bool)
    (rs : List (CohFusion.Core.MicroReceipt α))
    (threshold : α)
    [LE α] [DecidableRel (fun (x y : α) => x ≥ y)] : CohFusion.Core.Decision :=
  match rs with
  | [] => CohFusion.Core.Decision.accept
  | _ =>
    -- Using a boolean version of the check for runtime evaluation
    let rec checkLinked : List (CohFusion.Core.MicroReceipt α) → Bool
      | [] => true
      | [_] => true
      | r1 :: r2 :: rs => (r1.stateNext = r2.statePrev) && checkLinked (r2 :: rs)

    if checkLinked rs then
      rs.foldl (fun d r =>
        match d with
        | CohFusion.Core.Decision.accept => CohFusion.Runtime.verifyMicroReceipt validate r threshold
        | _ => d
      ) CohFusion.Core.Decision.accept
    else
      CohFusion.Core.Decision.reject CohFusion.Core.RejectCode.stateHashLinkFail

end CohFusion.Runtime
