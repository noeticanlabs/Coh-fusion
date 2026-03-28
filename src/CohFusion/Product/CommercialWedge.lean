import CohFusion.Core.State
import CohFusion.Core.Decision
import CohFusion.Core.Receipt
import CohFusion.Geometry.Composition
import CohFusion.Product.HardwareCertificate
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize
import CohFusion.Runtime.VerifierSemantics

namespace CohFusion.Product.CommercialWedge

open CohFusion.Core
open CohFusion.Geometry
open CohFusion.Numeric
open CohFusion.Runtime

/--
  Deployment modes for the commercial wedge.
  - replay: offline verification of historical traces
  - shadow: online monitoring without control intervention
  - advisory: online monitoring with operator alerts
  - hard_gate: automated rejection authority
-/
inductive DeploymentMode
  | replay
  | shadow
  | advisory
  | hard_gate
  deriving Repr, DecidableEq

/-- Public decision outcome for the commercial wedge. -/
inductive WedgeDecision
  | allow
  | warn (msg : String)
  | reject (code : RejectCode) (msg : String)
  deriving Repr, DecidableEq

/--
  The Commercial Fusion Controller Wedge.
  This is the primary product object encapsulating the certified hardware,
  the public risk envelope, and the deployment policy.
-/
structure CommercialWedge where
  mode          : DeploymentMode
  certificate   : HardwareCertificate
  risk_params   : ParamsFus QFixed

  -- Public Envelope Constraints
  threshold     : QFixed
  defect_limit  : QFixed

  /--
    Gamma oplax: spend discount / safety discount factor.
    - gamma = 0 recovers full spend (plain oplax law)
    - gamma > 0 means runtime conservatively discounts claimed authority
    This is a commercial feature: trusted authority retention factor.
  -/
  gamma_oplax   : QFixed

  -- Operating Regime
  regime_id     : String
  deriving Repr

/--
  Public Product Contract: Observable Channels.
  These are the primary signals consumed by the wedge.
-/
structure ObservableChannels where
  vde_displacement : QFixed -- Z
  vde_velocity     : QFixed -- vZ
  vde_actuator     : QFixed -- I_act
  tear_width       : QFixed -- W
  tear_growth      : QFixed -- vW
  tear_actuator    : QFixed -- I_cd
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Map observables to the internal flat State6. -/
def toState6 (c : ObservableChannels) : State6 QFixed :=
  { Z     := c.vde_displacement,
    vZ    := c.vde_velocity,
    I_act := c.vde_actuator,
    W     := c.tear_width,
    vW    := c.tear_growth,
    I_cd  := c.tear_actuator }

/--
  The Public Wedge Decision Logic.
  Dispatches based on deployment mode.
-/
def decide (wedge : CommercialWedge) (outcome : Decision) : WedgeDecision :=
  match wedge.mode with
  | DeploymentMode.replay =>
      match outcome with
      | Decision.accept => WedgeDecision.allow
      | Decision.reject code => WedgeDecision.reject code s!"REPLAY_FAILURE: {repr code}"
  | DeploymentMode.shadow =>
      match outcome with
      | Decision.accept => WedgeDecision.allow
      | Decision.reject code => WedgeDecision.warn s!"SHADOW_VIOLATION: {repr code}"
  | DeploymentMode.advisory =>
      match outcome with
      | Decision.accept => WedgeDecision.allow
      | Decision.reject code => WedgeDecision.warn s!"ADVISORY_ALERT: {repr code}"
  | DeploymentMode.hard_gate =>
      match outcome with
      | Decision.accept => WedgeDecision.allow
      | Decision.reject code => WedgeDecision.reject code s!"HARD_GATE_TRIP: {repr code}"


/--
  Evaluate the joint public risk functional VgeomFus.
  This is the core metric for the safety envelope.
-/
def evaluateRisk (wedge : CommercialWedge) (state : State6 QFixed) : QFixed :=
  VgeomFus wedge.risk_params (CohFusion.Geometry.toStateFus state)

/--
  Affordability Gate: Strict dominance of authority over defect.
  Lawful operation requires certified authority to strictly dominate priced defect.
-/
def isAffordable (_wedge : CommercialWedge) (defect authority : QFixed) : Bool :=
  defect < authority

/--
  End-to-end product runtime path:
  construct a micro-receipt, call the deterministic verifier, and map to wedge decision.

  NOTE: This is the orchestration entry point. The actual verifyRV call requires
  typeclass instances (LE, LT, Add, Sub, Mul, HPow, OfNat) for QFixed, which are
  available. Full integration with Runtime.VerifierSemantics.verifyRV will be
  completed in the next phase after typeclass infrastructure stabilizes.

  For now, this returns a basic allow decision that maps to the wedge's mode.
-/
def evaluateTransition
    (wedge : CommercialWedge)
    (expectedState nextState : ObservableChannels)
    (spend defect : QFixed) : WedgeDecision :=
  -- Orchestration: ingest observables -> build state -> evaluate risk -> evaluate affordability
  let state6 := toState6 nextState
  let risk := evaluateRisk wedge state6

  -- Affordability check (simplified for now)
  let affordable := isAffordable wedge defect spend

  -- Map to decision based on mode
  match wedge.mode with
  | DeploymentMode.replay =>
    if risk ≤ wedge.threshold && affordable then
      WedgeDecision.allow
    else
      WedgeDecision.reject RejectCode.thresholdExceeded "REPLAY_FAILURE"
  | DeploymentMode.shadow =>
    if risk ≤ wedge.threshold && affordable then
      WedgeDecision.allow
    else
      WedgeDecision.warn "SHADOW_VIOLATION"
  | DeploymentMode.advisory =>
    if risk ≤ wedge.threshold && affordable then
      WedgeDecision.allow
    else
      WedgeDecision.warn "ADVISORY_ALERT"
  | DeploymentMode.hard_gate =>
    if risk ≤ wedge.threshold && affordable then
      WedgeDecision.allow
    else
      WedgeDecision.reject RejectCode.thresholdExceeded "HARD_GATE_TRIP"

end CohFusion.Product.CommercialWedge
