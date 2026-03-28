import Lean.Data.Json
import CohFusion.Numeric.QFixed

namespace CohFusion.Numeric

/-- Canonical decimal string representation of QFixed.
    Produces a string like "1.5" or "-2.75" with proper sign handling. -/
def toCanonicalDecimal (q : QFixed) : String :=
  let raw := q.raw
  let sign := if raw < 0 then "-" else ""
  let absRaw := Int.natAbs raw
  let intPart := absRaw / scale
  let fracPart := absRaw % scale
  let fracStr := (fracPart / (scale / 1000000000000000)).toNat.repr
  if fracPart = 0 then
    sign ++ intPart.toNat.repr
  else
    sign ++ intPart.toNat.repr ++ "." ++ fracStr

/--
  Strict fixed-point serialization.
  Rejects JSON numbers to prevent float contamination.
  Expects canonical decimal string representation.
-/
instance : Lean.FromJson QFixed where
  fromJson? j :=
    match j with
    | Lean.Json.str s =>
      QFixed.fromDecimalString s
    | Lean.Json.num _ => Except.error "REJECT: Floating-point numbers forbidden in Coh profile. Use string-encoded values."
    | _ => Except.error "Expected string for QFixed"

instance : Lean.ToJson QFixed where
  toJson q := Lean.Json.str (toCanonicalDecimal q)

/-- Canonical byte serialization for numeric types. -/
class CanonicalSerialize (α : Type) where
  toCanonicalBytes : α → ByteArray

end CohFusion.Numeric
