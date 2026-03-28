import CohFusion.Core.Receipt
import CohFusion.Crypto.Digest
import CohFusion.Crypto.Serialize

namespace CohFusion.Runtime

/-- Hash-bounded receipt: binds receipt to digest/serialization constraints. -/
structure HashBoundedReceipt (α : Type) where
  receipt : CohFusion.Core.MicroReceipt α
  digest  : CohFusion.Crypto.Digest
  deriving DecidableEq

/-- Compute digest from receipt using canonical serialization. -/
def computeDigest [CohFusion.Crypto.Hasher] [CohFusion.Crypto.CanonicalSerialize (CohFusion.Core.MicroReceipt α)]
    (r : CohFusion.Core.MicroReceipt α) : CohFusion.Crypto.Digest :=
  CohFusion.Crypto.Hasher.hashBytes (CohFusion.Crypto.CanonicalSerialize.toCanonicalBytes r)

end CohFusion.Runtime
