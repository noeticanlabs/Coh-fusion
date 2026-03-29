import CohFusion.Core.Receipt
import CohFusion.Runtime.VerifierSemantics
import CohFusion.Geometry.Composition
import CohFusion.Crypto.Digest

namespace CohFusion.Runtime

open CohFusion.Core
open CohFusion.Geometry

/- Runtime bridge: connects low-level receipts to high-level verifier semantics. -/

/-- Bridge verifier: runs the verifier on a stream of fusion receipts.
    Now uses unified FusionReceipt type. -/
def bridgeVerifier
    {α : Type}
    [LinearOrder α] [Add α] [Sub α] [Mul α] [HPow α Nat α] [OfNat α 1]
    (p : ParamsFus α)
    (rs : List (FusionReceipt α))
    (initialState : State6 α)
    (threshold : α)
    (defectLimit : α)
    (gamma : α)
    : Decision :=
  match rs with
  | [] => Decision.accept
  | _ =>
    -- Check sequence linkage first
    if traceLinked rs == false then
      Decision.reject RejectCode.stateHashLinkFail
    else
      -- Verify each step, updating the expected state as we go
      let rec verifyTrace (trace : List (FusionReceipt α)) (currentExpected : State6 α) : Decision :=
        match trace with
        | [] => Decision.accept
        | r :: tail =>
          match verifyRV p r currentExpected threshold defectLimit gamma with
          | Decision.accept => verifyTrace tail r.stateNext
          | d => d

      verifyTrace rs initialState

end CohFusion.Runtime
