import Mathlib.Order.Basic
import CohFusion.Numeric.Policy

set_option linter.unusedVariables false

namespace CohFusion.Numeric

/--
  Fixed-point rational with a rigid 64-bit fractional part (Q64.64 profile).
  Internally uses Lean's arbitrary-precision `Int`.
  Scaling factor is `2^64`.
-/
structure QFixed where
  raw : Int
  deriving Repr, DecidableEq, Inhabited

namespace QFixed

/-- Number of fractional bits. -/
def fracBits : Nat := 64

/-- Scaling factor `2^64`. -/
def scale : Int := (2 : Int) ^ fracBits

instance : Zero QFixed := ⟨⟨0⟩⟩
instance : One QFixed := ⟨⟨scale⟩⟩

/-- Named aliases for convenience. -/
def zero : QFixed := 0
def one : QFixed := 1

/-- From `Int` to Q64.64. -/
def fromInt (i : Int) : QFixed := ⟨i * scale⟩

/-- Addition. -/
def add (a b : QFixed) : QFixed := ⟨a.raw + b.raw⟩

/-- Subtraction. -/
def sub (a b : QFixed) : QFixed := ⟨a.raw - b.raw⟩

/-- Negation. -/
def neg (a : QFixed) : QFixed := ⟨-a.raw⟩

/--
  Multiplication with Q64.64 rescaling:
  `(a.raw * b.raw) / scale`.
-/
def mul (a b : QFixed) : QFixed :=
  ⟨(a.raw * b.raw) / scale⟩

/--
  Total but unsafe division operator.
  Returns `0` on division by zero so the term remains definable.
  For verifier/consensus logic, prefer `div?` below and reject zero denominators.
-/
def div (a b : QFixed) : QFixed :=
  if b.raw = 0 then 0 else ⟨(a.raw * scale) / b.raw⟩

/-- Safe division for consensus-critical paths. -/
def div? (a b : QFixed) : Except String QFixed :=
  if b.raw = 0 then
    Except.error "Division by zero"
  else
    Except.ok ⟨(a.raw * scale) / b.raw⟩

instance : Add QFixed := ⟨add⟩
instance : Sub QFixed := ⟨sub⟩
instance : Neg QFixed := ⟨neg⟩
instance : Mul QFixed := ⟨mul⟩
instance : Div QFixed := ⟨div⟩

/-- Natural-number exponentiation. -/
def pow (a : QFixed) (n : Nat) : QFixed :=
  match n with
  | 0 => 1
  | Nat.succ k => a * pow a k

instance : HPow QFixed Nat QFixed := ⟨pow⟩

instance : LT QFixed := ⟨fun a b => a.raw < b.raw⟩
instance : LE QFixed := ⟨fun a b => a.raw ≤ b.raw⟩

instance : DecidableRel (fun a b : QFixed => a < b) :=
  fun a b => inferInstanceAs (Decidable (a.raw < b.raw))

instance : DecidableRel (fun a b : QFixed => a ≤ b) :=
  fun a b => inferInstanceAs (Decidable (a.raw ≤ b.raw))

/-- Convert to `Float` for display/debugging only. -/
def toFloat (q : QFixed) : Float :=
  Float.ofInt q.raw / Float.ofInt scale

/--
  From `Float` for display/debugging only.
  This is not consensus-safe and should never be used in verifier logic.
  It preserves sign, unlike the original version.
-/
def fromFloat (f : Float) : QFixed :=
  let scaled := f * Float.ofInt scale
  let mag : Int := Int.ofNat (Float.abs scaled).toUInt64.toNat
  ⟨if scaled < 0 then -mag else mag⟩

/-- Helper: parse a nonempty decimal digit string as `Nat`. -/
private def parseNatString (label s : String) : Except String Nat :=
  if s.isEmpty then
    Except.error s!"Missing {label} digits"
  else
    match s.toNat? with
    | some n => Except.ok n
    | none => Except.error s!"Invalid {label}: {s}"

/-- Exact decimal string parser for Q64.64.
    Accepts: optional sign, integer digits, optional decimal fraction.
    Format: `[+-]?[0-9]+(\.[0-9]+)?`
    Uses exact integer arithmetic with `2^64` scaling.
-/
def fromDecimalString (s : String) : Except String QFixed :=
  if s.isEmpty then
    Except.error "Empty string"
  else
    let chars := s.toList
    let (isNeg, body) :=
      match chars with
      | [] => (false, "")
      | '+' :: cs => (false, String.mk cs)
      | '-' :: cs => (true, String.mk cs)
      | _ => (false, s)
    match body.splitOn "." with
    | [intPart] =>
        match parseNatString "integer" intPart with
        | Except.error e => Except.error e
        | Except.ok nInt =>
            let raw : Int := (nInt : Int) * scale
            Except.ok ⟨if isNeg then -raw else raw⟩
    | [intPart, fracPart] =>
        match parseNatString "integer" intPart, parseNatString "fractional" fracPart with
        | Except.ok nInt, Except.ok nFrac =>
            let denom : Int := ((10 : Nat) ^ fracPart.length : Nat)
            let intRaw : Int := (nInt : Int) * scale
            let fracRaw : Int := ((nFrac : Int) * scale) / denom
            let raw := intRaw + fracRaw
            Except.ok ⟨if isNeg then -raw else raw⟩
        | Except.error e, _ => Except.error e
        | _, Except.error e => Except.error e
    | _ => Except.error "Invalid format: multiple decimal points"

end QFixed

instance : ConsensusSafe QFixed := ⟨⟩

end CohFusion.Numeric
