import CohFusion.Core.State
import CohFusion.Core.Decision
import CohFusion.Core.Receipt
import CohFusion.Geometry.Composition
import CohFusion.Product.HardwareCertificate
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize

namespace CohFusion.Product.CommercialWedge

open CohFusion.Core
open CohFusion.Geometry
open CohFusion.Numeric

/--
  Deployment modes for the commercial wedge.
  - replay: offline verification of historical traces
  - shadow: online monitoring without control intervention
  - advisory: online monitoring with operator alerts
  - hard_gate: online verification with automated shutdown authority
-/
inductive DeploymentMode
  | replay
  | shadow
  | advisory
  | hard_gate
  deriving Repr, DecidableEq

/-- Public Decision outcome for the commercial wedge. -/
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
  Affordability Law (FUS-1): Authority vs Burn Defect.
  Computes if the available control authority can dominate the certified defect.
-/
def isAffordable (_wedge : CommercialWedge) (defect : QFixed) (authority : QFixed) : Bool :=
  defect ≤ authority

end CohFusion.Product.CommercialWedge
