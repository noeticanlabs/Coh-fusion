import CohFusion.Numeric.QFixed

namespace Coh.Numeric

/--
An outward-rounded interval guaranteeing the true real value is bounded
between [lower, upper]. The type formally demands lower ≤ upper.
-/
structure Interval where
  lower : QFixed
  upper : QFixed
  valid : lower ≤ upper
  deriving Repr

namespace Interval

/-- Exact interval addition. Safe and exact for QFixed. -/
def add (x y : Interval) : Interval :=
  let new_lower := x.lower + y.lower
  let new_upper := x.upper + y.upper
  have h_valid : new_lower ≤ new_upper := by
    -- Proof: x.lower ≤ x.upper and y.lower ≤ y.upper implies x.lower + y.lower ≤ x.upper + y.upper
    have hx : x.lower.raw ≤ x.upper.raw := x.valid
    have hy : y.lower.raw ≤ y.upper.raw := y.valid
    exact QFixed.add_le_add hx hy
  ⟨new_lower, new_upper, h_valid⟩

/-- Subtraction of intervals: [a, b] - [c, d] = [a - d, b - c] -/
def sub (x y : Interval) : Interval :=
  let new_lower := x.lower - y.upper
  let new_upper := x.upper - y.lower
  have h_valid : new_lower ≤ new_upper := by
    -- Proof: y.upper ≥ y.lower and x.lower ≤ x.upper implies x.lower - y.upper ≤ x.upper - y.lower
    have hy : y.upper.raw ≥ y.lower.raw := y.valid
    have hx : x.lower.raw ≤ x.upper.raw := x.valid
    exact QFixed.sub_le_sub hx hy
  ⟨new_lower, new_upper, h_valid⟩

/--
Multiplication of strictly positive intervals.
Uses outward rounding: truncates the lower bound, ceilings the upper bound.
This physically guarantees the macroscopic defect E_model never leaks outside the budget.
-/
def mulPositive (x y : Interval) (hx : QFixed.zero ≤ x.lower) (hy : QFixed.zero ≤ y.lower) : Interval :=
  let new_lower := QFixed.mulTruncate x.lower y.lower
  let new_upper := QFixed.mulCeil x.upper y.upper
  have h_valid : new_lower ≤ new_upper := by
    -- For non-negative operands: floor ≤ ceil mathematically holds
    exact QFixed.mulTruncate_le_mulCeil x.lower y.lower x.upper y.upper hx hy x.valid y.valid
  ⟨new_lower, new_upper, h_valid⟩

/-- Verifier constraint: Check if a state scalar fits securely within an interval -/
def contains (i : Interval) (val : QFixed) : Bool :=
  (i.lower ≤ val) && (val ≤ i.upper)

end Interval
end Coh.Numeric
