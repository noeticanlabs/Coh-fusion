namespace CohFusion.Crypto

/-- Canonical byte serialization interface. -/
class CanonicalSerialize (α : Type) where
  toCanonicalBytes : α → ByteArray

end CohFusion.Crypto
