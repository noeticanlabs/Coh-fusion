namespace CohFusion.Crypto

/-- Abstract digest type for hash interface. -/
structure Digest where
  bytes : ByteArray
  deriving DecidableEq

/-- Hash function interface. -/
class Hasher where
  hashBytes : ByteArray → Digest

end CohFusion.Crypto
