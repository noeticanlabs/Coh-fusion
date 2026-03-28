namespace CohFusion.Numeric

/-- Canonical byte serialization for numeric types. -/
class CanonicalSerialize (α : Type) where
  toCanonicalBytes : α → ByteArray

end CohFusion.Numeric
