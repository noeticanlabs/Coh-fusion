import CohFusion.Core.Receipt
import CohFusion.Runtime.VerifierSemantics

namespace CohFusion.Runtime

/-- Bridge: compiler theorem from certified continuous transition into discrete receipt. -/
structure Bridge (Cont α : Type) where
  compile        : Cont → Core.MicroReceipt α
  soundnessProof : Prop

/-- Verify bridge: check continuous state compiles to valid receipt. -/
def verifyBridge
    (compile : Cont → Core.MicroReceipt α)
    (validate : Core.MicroReceipt α → Bool)
    (s : Cont) : Core.Decision :=
  let r := compile s
  verifyMicroReceipt validate r

end CohFusion.Runtime
