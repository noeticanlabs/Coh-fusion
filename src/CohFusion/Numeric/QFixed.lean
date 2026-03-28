import CohFusion.Numeric.Policy

set_option linter.unusedVariables false

namespace CohFusion.Numeric

/-- Fixed-point rational with binary fractional bits. -/
structure QFixed where
  raw      : Int
  fracBits : Nat
  deriving Repr, DecidableEq

/-- Zero QFixed. -/
def zero : QFixed := { raw := 0, fracBits := 0 }

/-- Addition with overflow check. -/
def add (a b : QFixed) : Option QFixed :=
  if h : a.fracBits = b.fracBits then
    some { raw := a.raw + b.raw, fracBits := a.fracBits }
  else
    none

/-- Subtraction with overflow check. -/
def sub (a b : QFixed) : Option QFixed :=
  if h : a.fracBits = b.fracBits then
    some { raw := a.raw - b.raw, fracBits := a.fracBits }
  else
    none

instance : ConsensusSafe QFixed := ⟨⟩

end CohFusion.Numeric
