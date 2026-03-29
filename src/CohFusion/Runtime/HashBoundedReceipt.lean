import CohFusion.Core.Receipt
import CohFusion.Crypto.Digest
import CohFusion.Crypto.Serialize

namespace CohFusion.Runtime

/-- Hash-bounded receipt: binds receipt to digest/serialization constraints.
Deprecated: Use FusionReceipt with digest field instead. -/
@[deprecated "Use FusionReceipt with digest field instead" ]
structure HashBoundedReceipt (α : Type) where
  receipt : CohFusion.Core.FusionReceipt α
  digest  : CohFusion.Crypto.Digest
  deriving DecidableEq

/-- Compute digest from receipt using canonical serialization. -/
def computeDigest [CohFusion.Crypto.Hasher] [CohFusion.Crypto.CanonicalSerialize (CohFusion.Core.FusionReceipt α)]
    (r : CohFusion.Core.FusionReceipt α) : CohFusion.Crypto.Digest :=
  CohFusion.Crypto.Hasher.hashBytes (CohFusion.Crypto.CanonicalSerialize.toCanonicalBytes r)

end CohFusion.Runtime
