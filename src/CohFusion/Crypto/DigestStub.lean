import CohFusion.Crypto.Digest

namespace CohFusion.Crypto

/-- Non-cryptographic development stub. Never valid for production chain integrity. -/
def stubDigest : Digest :=
  { bytes := ByteArray.mk (Array.mk (List.replicate 32 (UInt8.ofNat 0))) }

instance : Hasher where
  hashBytes _ := stubDigest

end CohFusion.Crypto
