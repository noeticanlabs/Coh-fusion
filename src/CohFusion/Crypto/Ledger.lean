import CohFusion.Crypto.Digest
import CohFusion.Crypto.Serialize

namespace CohFusion.Crypto

/-- Update digest with new data using hasher and serializer. -/
def updateDigest [Hasher] [CanonicalSerialize α] (prev : Digest) (x : α) : Digest :=
  Hasher.hashBytes (prev.bytes ++ CanonicalSerialize.toCanonicalBytes x)

end CohFusion.Crypto
