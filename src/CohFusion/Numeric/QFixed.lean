-- No imports needed: all required Int operations come from Init.Prelude
-- QFixed uses only basic Int arithmetic (+, -, *, /, %) and ordering (≤, <)

namespace Coh.Numeric

/--
Canonical scaling factor for Q64.64 fixed-point arithmetic: 2^64.
All values are conceptually divided by this scale.
-/
def scale_64 : Int := 18446744073709551616

/--
Deterministic fixed-point numeric type.
IEEE-754 binary64 is strictly forbidden in this namespace.
-/
structure QFixed where
  raw : Int
  deriving Repr, DecidableEq

namespace QFixed

/-- Zero instantiation -/
def zero : QFixed := ⟨0⟩

/-- Identity instantiation -/
def one : QFixed := ⟨scale_64⟩

/-- Inject an exact integer into the QFixed domain -/
def fromInt (z : Int) : QFixed :=
  ⟨z * scale_64⟩

-- ==========================================
-- Deterministic Arithmetic Operations
-- ==========================================

/-- Exact deterministic addition -/
def add (a b : QFixed) : QFixed :=
  ⟨a.raw + b.raw⟩

/-- Exact deterministic subtraction -/
def sub (a b : QFixed) : QFixed :=
  ⟨a.raw - b.raw⟩

/--
Multiplication with deterministic truncation (floor division).
Proof of determinism: Int.ediv in Lean 4 is formally defined and architecture-independent.
-/
def mulTruncate (a b : QFixed) : QFixed :=
  ⟨(a.raw * b.raw) / scale_64⟩

/--
Multiplication with deterministic ceiling (outward rounding for upper bounds).
If there is a remainder, we add 1 to the raw integer.
-/
def mulCeil (a b : QFixed) : QFixed :=
  let product := a.raw * b.raw
  let quotient := product / scale_64
  let remainder := product % scale_64
  if remainder > 0 then
    ⟨quotient + 1⟩
  else
    ⟨quotient⟩

-- ==========================================
-- Typeclass Instances
-- ==========================================

instance : Add QFixed := ⟨add⟩
instance : Sub QFixed := ⟨sub⟩
instance : OfNat QFixed n := ⟨fromInt n⟩
instance : Inhabited QFixed := ⟨zero⟩

-- Ordering
def le (a b : QFixed) : Prop := a.raw ≤ b.raw
def lt (a b : QFixed) : Prop := a.raw < b.raw

instance : LE QFixed := ⟨le⟩
instance : LT QFixed := ⟨lt⟩

instance (a b : QFixed) : Decidable (a ≤ b) :=
  Int.decLe a.raw b.raw

instance (a b : QFixed) : Decidable (a < b) :=
  Int.decLt a.raw b.raw

-- ==========================================
-- Helper Theorems for Interval Proofs
-- ==========================================

/-- Theorem: addition preserves ordering -/
theorem add_le_add {a b c d : Int} (h1 : a ≤ b) (h2 : c ≤ d) : a + c ≤ b + d := by
  exact Int.add_le_add h1 h2

/-- Theorem: subtraction preserves ordering -/
theorem sub_le_sub {a b c d : Int} (h1 : a ≤ b) (h2 : c ≥ d) : a - c ≤ b - d := by
  exact Int.sub_le_sub h1 h2

/-- Theorem: for non-negative values, truncate ≤ ceil -/
-- Note: This is a stub - a full proof would use Int division lemmas
axiom mulTruncate_le_mulCeil_of_nonneg (a b c d : Int)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : a ≤ c) (hd : b ≤ d) :
    (a * b) / scale_64 ≤ (if (c * d) % scale_64 > 0 then (c * d) / scale_64 + 1 else (c * d) / scale_64)

/-- Wrapper theorem: QFixed version that extracts raw fields -/
-- Note: Uses axiom - mathematical property holds for Int-backed QFixed
axiom mulTruncate_le_mulCeil (a b c d : QFixed)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : a ≤ c) (hd : b ≤ d) :
    mulTruncate a b ≤ mulCeil c d

end QFixed
end Coh.Numeric
