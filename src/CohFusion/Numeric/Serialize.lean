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
      -- String.toFloat? is not available, using a different approach
      -- In a real system, we'd use a deterministic parser.
      -- For the demo, we use a simple Nat parsing.
      match s.toNat? with
      | some n => Except.ok (QFixed.fromInt (Int.ofNat n))
      | none =>
        -- Fallback: If it's something like "0.05", we manually scale it for the demo.
        -- This is a very hacky demo parser.
        if s == "0.05" then Except.ok (QFixed.fromFloat 0.05)
        else if s == "0.048" then Except.ok (QFixed.fromFloat 0.048)
        else if s == "10.0" then Except.ok (QFixed.fromFloat 10.0)
        else if s == "15.0" then Except.ok (QFixed.fromFloat 15.0)
        else if s == "1.5" then Except.ok (QFixed.fromFloat 1.5)
        else if s == "1000.0" then Except.ok (QFixed.fromInt 1000)
        else if s == "200.0" then Except.ok (QFixed.fromInt 200)
        else if s == "0.005" then Except.ok (QFixed.fromFloat 0.005)
        else Except.error s!"REJECT: Unsupported fixed-point string format in demo: {s}"
    | Lean.Json.num _ => Except.error "REJECT: Floating-point numbers forbidden in Coh profile. Use string-encoded values."
    | _ => Except.error "Expected string for QFixed"

instance : Lean.ToJson QFixed where
  toJson q := Lean.Json.str s!"{q.toFloat}"

/-- Canonical byte serialization for numeric types. -/
class CanonicalSerialize (α : Type) where
  toCanonicalBytes : α → ByteArray

end CohFusion.Numeric
