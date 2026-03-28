import CohFusion.Core.State

namespace CohFusion.Core

/-- Micro-receipt for a single control step. -/
structure MicroReceipt (α : Type) where
  statePrev      : State6 α
  stateNext      : State6 α
  spendAuth      : α
  defectDeclared : α
  deriving Repr, DecidableEq

/-- Total spend across a trace. -/
def totalSpend [OfNat α 0] [HAdd α α α] : List (MicroReceipt α) → α
  | []      => 0
  | r :: rs => r.spendAuth + totalSpend rs

/-- Total defect across a trace. -/
def totalDefect [OfNat α 0] [HAdd α α α] : List (MicroReceipt α) → α
  | []      => 0
  | r :: rs => r.defectDeclared + totalDefect rs

/-- Final state after applying a trace. -/
def finalState : State6 α → List (MicroReceipt α) → State6 α
  | anchor, []      => anchor
  | _,      r :: rs => finalState r.stateNext rs

end CohFusion.Core
