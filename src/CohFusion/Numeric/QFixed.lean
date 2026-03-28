import Mathlib.Order.Basic
import CohFusion.Numeric.Policy

set_option linter.unusedVariables false

namespace CohFusion.Numeric

/--
  Fixed-point rational with rigid 64-bit fractional part (Q64.64 profile).
  Internally uses Lean's arbitrary-precision `Int`.
  Scaling factor is 2^64.
-/
structure QFixed where
  raw : Int
  deriving Repr, DecidableEq, Inhabited

namespace QFixed

def scale : Int := 18446744073709551616 -- 2^64

/-- Zero QFixed. -/
def zero : QFixed := ⟨0⟩

/-- One QFixed. -/
def one : QFixed := ⟨scale⟩

/-- From Int to QFixed. -/
def fromInt (i : Int) : QFixed := ⟨i * scale⟩

/-- Addition. -/
def add (a b : QFixed) : QFixed := ⟨a.raw + b.raw⟩

/-- Subtraction. -/
def sub (a b : QFixed) : QFixed := ⟨a.raw - b.raw⟩

/--
  Multiplication with 64-bit shift.
  (a * b) / scale
-/
def mul (a b : QFixed) : QFixed :=
  ⟨(a.raw * b.raw) / scale⟩

/-- Division. -/
def div (a b : QFixed) : QFixed :=
  ⟨(a.raw * scale) / b.raw⟩

instance : Add QFixed := ⟨add⟩
instance : Sub QFixed := ⟨sub⟩
instance : Mul QFixed := ⟨mul⟩
instance : Div QFixed := ⟨div⟩

def pow (a : QFixed) (n : Nat) : QFixed :=
  match n with
  | 0 => one
  | 1 => a
  | n+1 => mul a (pow a n)

instance : HPow QFixed Nat QFixed := ⟨pow⟩

instance : LT QFixed := ⟨λ a b => a.raw < b.raw⟩
instance : LE QFixed := ⟨λ a b => a.raw ≤ b.raw⟩

instance : DecidableRel (LT.lt : QFixed → QFixed → Prop) :=
  λ a b => (inferInstance : Decidable (a.raw < b.raw))

instance : DecidableRel (LE.le : QFixed → QFixed → Prop) :=
  λ a b => (inferInstance : Decidable (a.raw ≤ b.raw))

-- Manual decidability for greater-than: a > b ≡ b < a
instance (a b : QFixed) : Decidable (a > b) :=
  inferInstanceAs (Decidable (b < a))

-- Derive DecidableEq from the structure's raw field equality
-- Uses the derived DecidableEq on the structure itself
instance : DecidableEq QFixed := inferInstance

/-- Convert to Float (for logging/display only, not for core logic). -/
def toFloat (q : QFixed) : Float :=
  Float.ofInt q.raw / Float.ofInt scale

/-- From Float (for ingestion, with strict checking in serializer). -/
def fromFloat (f : Float) : QFixed :=
  ⟨(f * Float.ofInt scale).toUInt64.toNat⟩

end QFixed

instance : ConsensusSafe QFixed := ⟨⟩

end CohFusion.Numeric
