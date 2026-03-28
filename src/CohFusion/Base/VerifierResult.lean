namespace Coh.Base

/--
The terminal enumeration for the deterministic referee.
A Coh verifier must return one of these exact states.
-/
inductive VerifierResult where
  /-- The transition is legally certified and the defect is affordable. -/
  | ACCEPT
  /-- The starting or ending state violates absolute topological bounds. -/
  | REJECT_STATE_INVALID
  /-- The cryptographic chain digest or canonical signature is broken. -/
  | REJECT_UNAUTHORIZED_TRANSITION
  /-- The physics are valid, but the hardware lacks the budget to execute the maneuver. -/
  | REJECT_UNAFFORDABLE_BURN
  /-- The claimed macroscopic safety bounds are violated by the transition. -/
  | REJECT_THERMODYNAMIC_FAIL
  deriving Repr, DecidableEq

end Coh.Base
