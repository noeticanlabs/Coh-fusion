namespace CohFusion.Core

/-- Rejection codes for the decision monad. -/
inductive RejectCode
  | schemaInvalid
  | chainDigestMismatch
  | stateHashLinkFail
  | thresholdExceeded
  | defectOutOfBounds
  | oplaxViolation
  | overflow
  | unauthorizedTransition
  | unaffordableBurn
  deriving Repr, DecidableEq

/-- Decision outcome: either accept or reject with a code. -/
inductive Decision
  | accept
  | reject : RejectCode → Decision
  deriving Repr, DecidableEq

end CohFusion.Core
