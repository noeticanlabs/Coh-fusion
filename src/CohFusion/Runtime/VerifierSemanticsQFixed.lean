import CohFusion.Runtime.VerifierSemantics
import CohFusion.Numeric.QFixed

namespace CohFusion.Runtime

/--
  Runtime-specialized RV Kernel using QFixed.
  This provides a concrete instantiation of the generic verifyRV
  for the QFixed numeric type, avoiding any type class ambiguity.
-/
def verifyRV_QFixed
    (p : ParamsFus QFixed)
    (r : MicroReceipt QFixed)
    (expectedState : State6 QFixed)
    (threshold : QFixed)
    (defectLimit : QFixed)
    (gamma : QFixed)
    : Decision :=
  -- 1. State Link Gate: Ensure the receipt follows the expected state.
  if r.statePrev ≠ expectedState then
    Decision.reject RejectCode.unauthorizedTransition

  -- 2. Threshold Gate: Ensure next state is within the public safety envelope.
  --     Closed sublevel set: reject only if V > threshold (safe if V ≤ threshold)
  else if VgeomFus p (toStateFus r.stateNext) > threshold then
    Decision.reject RejectCode.thresholdExceeded

  -- 3. Defect Gate: Ensure declared defect is within bounds.
  --     Reject only if defectDeclared > defectLimit
  else if r.defectDeclared > defectLimit then
    Decision.reject RejectCode.defectOutOfBounds

  -- 4. Oplax Gate: Verify the contractive/dissipative inequality.
  --     Logic: V(s') ≤ V(s) - (1-γ) * spend + defect
  else if VgeomFus p (toStateFus r.stateNext) >
         VgeomFus p (toStateFus r.statePrev) - (QFixed.one - gamma) * r.spendAuth + r.defectDeclared then
    Decision.reject RejectCode.oplaxViolation

  else
    Decision.accept

/-- Soundness of a trace using QFixed. -/
def traceLinked_QFixed : List (MicroReceipt QFixed) → Bool
  | [] => true
  | [_] => true
  | r1 :: r2 :: rs => (r1.stateNext = r2.statePrev) && traceLinked_QFixed (r2 :: rs)

end CohFusion.Runtime
