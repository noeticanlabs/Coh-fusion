import Mathlib.Order.Basic
import Mathlib.Algebra.Ring.Basic
import CohFusion.Core.Receipt
import CohFusion.Core.Decision
import CohFusion.Geometry.Composition

set_option checkBinderAnnotations false

namespace CohFusion.Runtime

open CohFusion.Core
open CohFusion.Geometry

/-- RV (Runtime Verifier) Kernel for Coh-Fusion.
    This implements the deterministic transition check for a single micro-receipt. -/
def verifyRV
    {α : Type}
    [Ring α] [LinearOrder α]
    [Add α] [Sub α] [Mul α] [HPow α Nat α] [OfNat α 1]
    (p : ParamsFus α)
    (r : MicroReceipt α)
    (expectedState : State6 α)
    (threshold : α)
    (defectLimit : α)
    (gamma : α) -- dissipation/discount factor for oplax
    : Decision :=
  -- 1. State Link Gate: Ensure the receipt follows the expected state.
  if r.statePrev ≠ expectedState then
    Decision.reject RejectCode.unauthorizedTransition

  -- 2. Threshold Gate: Ensure next state is within the public safety envelope.
  else if VgeomFus p (toStateFus r.stateNext) ≥ threshold then
    Decision.reject RejectCode.thresholdExceeded

  -- 3. Defect Gate: Ensure declared defect is within bounds.
  else if r.defectDeclared ≥ defectLimit then
    Decision.reject RejectCode.defectOutOfBounds

  -- 4. Oplax Gate: Verify the contractive/dissipative inequality.
  -- Logic: V(s') ≤ V(s) - (1-γ) * spend + defect
  else if VgeomFus p (toStateFus r.stateNext) >
          VgeomFus p (toStateFus r.statePrev) - ((1 : α) - gamma) * r.spendAuth + r.defectDeclared then
    Decision.reject RejectCode.oplaxViolation

  else
    Decision.accept

/-- Soundness of a trace: all receipts in the trace are sequentially linked. -/
def traceLinked {α : Type} [DecidableEq α] : List (MicroReceipt α) → Bool
  | [] => true
  | [_] => true
  | r1 :: r2 :: rs => (r1.stateNext = r2.statePrev) && traceLinked (r2 :: rs)

end CohFusion.Runtime
