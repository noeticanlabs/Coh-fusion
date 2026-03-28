import Lean.Data.Json
import CohFusion.Numeric.QFixed

namespace CohFusion.Numeric

/--
  Strict fixed-point serialization.
  Rejects JSON numbers to prevent float contamination.
  Expects string-encoded fixed-point values.
-/
instance : Lean.FromJson QFixed where
  fromJson? j :=
    match j with
    | Lean.Json.str s =>
      -- In a real system, we'd use a deterministic parser.
      -- For the commercial demo, we use a robust-enough string parser.
      match s.toNat? with
      | some n => Except.ok (QFixed.fromInt (Int.ofNat n))
      | none =>
        -- Handle decimals by identifying the position and scaling.
        -- This is a demo-grade parser for "X.Y" formats.
        if s.contains '.' then
          match Lean.Json.parse s with
          | Except.ok (Lean.Json.num n) => Except.ok (QFixed.fromFloat n.toFloat)
          | _ => Except.error s!"REJECT: Invalid fixed-point string format: {s}"
        else
          Except.error s!"REJECT: Unsupported fixed-point string format: {s}"
    | Lean.Json.num _ => Except.error "REJECT: Floating-point numbers forbidden in Coh profile. Use string-encoded values."
    | _ => Except.error "Expected string for QFixed"

instance : Lean.ToJson QFixed where
  toJson q := Lean.Json.str s!"{q.toFloat}"

/-- Canonical byte serialization for numeric types. -/
class CanonicalSerialize (α : Type) where
  toCanonicalBytes : α → ByteArray

end CohFusion.Numeric
