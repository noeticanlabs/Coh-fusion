import Lean.Data.Json
import CohFusion.Numeric.QFixed

namespace CohFusion.Numeric

/-- Canonical decimal string representation of QFixed.
    Uses fixed-width 16-digit fractional part with left-padding, then trims trailing zeros.
    Produces strings like "1.5", "-2.75", "100" (no trailing .0). -/
def toCanonicalDecimal (q : QFixed) : String :=
  let raw := q.raw
  let sign := if raw < 0 then "-" else ""
  let absRaw := Int.natAbs raw
  let intPart := absRaw / scale
  let fracRaw := absRaw % scale

  -- Fixed 16-digit fractional width
  let fracStr := fracRaw.repr
  let paddedFrac := String.mk (List.replicate (16 - fracStr.length) '0' |>.append fracStr.toList)

  -- Trim trailing zeros
  let trimmedFrac := paddedFrac.reverse.dropWhile (fun c => c = '0').reverse

  if fracRaw = 0 then
    sign ++ intPart.toNat.repr
  else if trimmedFrac.isEmpty then
    sign ++ intPart.toNat.repr
  else
    sign ++ intPart.toNat.repr ++ "." ++ trimmedFrac

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
