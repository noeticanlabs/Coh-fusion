import CohFusion.Core.Receipt
import CohFusion.Crypto.Digest
import CohFusion.Crypto.Serialize

namespace CohFusion.Runtime

/-- Hash-bounded receipt: binds receipt to digest/serialization constraints. -/
structure HashBoundedReceipt (α : Type) where
  receipt : Core.MicroReceipt α
  digest  : Crypto.Digest
  deriving DecidableEq

/-- Compute digest from receipt using canonical serialization. -/
def computeDigest [Crypto.Hasher] [Crypto.CanonicalSerialize (Core.MicroReceipt α)]
    (r : Core.MicroReceipt α) : Crypto.Digest :=
  Crypto.Hasher.hashBytes (Crypto.CanonicalSerialize.toCanonicalBytes r)

end CohFusion.Runtime
