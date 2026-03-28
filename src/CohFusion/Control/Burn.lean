import Lean.Data.Json
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize

namespace CohFusion.Control.Burn

open CohFusion.Numeric

/-- Validity period for hardware certificates. -/
structure ValidityPeriod where
  not_before : String
  not_after  : String
  deriving Lean.FromJson, Lean.ToJson, Repr

/--
  Full Hardware Certificate Specification mirroring the JSON schema.
  Includes physical parameters and governance/security metadata.
-/
structure HardwareSpec where
  certificate_id     : String
  hardware_id        : String
  I_max              : QFixed
  I_dot_max          : QFixed
  tau_sensor         : QFixed
  timestamp          : String
  signature          : String
  validity_period    : ValidityPeriod
  certificate_type   : String
  root_of_trust      : String
  canon_profile_hash : String  -- Required for Step 3 metadata check
  deriving Lean.FromJson, Lean.ToJson, Repr

/-- Plasma state for burn verification. -/
structure PlasmaState where
  beta        : QFixed
  temperature : QFixed
  density     : QFixed
  deriving Lean.FromJson, Lean.ToJson, Repr

/-- Burn receipt for resource consumption tracking. -/
structure BurnReceipt where
  dt            : QFixed
  etaAvailable  : QFixed
  spend         : QFixed
  eModel        : QFixed
  eAct          : QFixed
  eSensor       : QFixed
  m_VDE         : QFixed -- Step 4 integration
  m_tear        : QFixed -- Step 4 integration
  deriving Lean.FromJson, Lean.ToJson, Repr

/-- Detailed result for the FUS-1 verifier. -/
inductive VerifierResult
  | accept
  | reject_invalid_envelope (msg : String)
  | reject_unauthorized_transition (msg : String)
  | reject_unaffordable_burn (msg : String)
  | reject_overflow (msg : String)
  deriving Repr

/-- Hardcoded Profile Hash for the demo. -/
def CANON_PROFILE_HASH_DEMO : String := "sha256:f123abc456"

/-- Heuristic parameters for FUS-1. -/
def beta_ignite : QFixed := QFixed.fromFloat 0.05
def delta_0     : QFixed := QFixed.fromFloat 10.0
def delta_min   : QFixed := QFixed.fromFloat 0.1
def C_slew      : QFixed := QFixed.fromFloat 50.0
def k_lag       : QFixed := QFixed.fromFloat 2.5

/--
  A. Boundary Layer Shrinkage (delta_active)
  delta_active(beta) = max(delta_min, delta_0 * (1 - beta/beta_ignite))
-/
def compute_delta_active (beta : QFixed) : QFixed :=
  let ratio := beta / beta_ignite
  let shrinkage := QFixed.one - ratio
  let delta := delta_0 * shrinkage
  if delta < delta_min then delta_min else delta

/--
  B. Required Slew Rate (I_dot_req)
  I_dot_req = C_slew / (delta_active)^2
-/
def compute_I_dot_req (delta_active : QFixed) : QFixed :=
  C_slew / (delta_active * delta_active)

/--
  C. Actuation Defect Inflation (E_act)
  E_act = k_lag * max(0, I_dot_req - hw.I_dot_max)
-/
def compute_actuation_defect (hw : HardwareSpec) (I_dot_req : QFixed) : QFixed :=
  if I_dot_req > hw.I_dot_max then
    k_lag * (I_dot_req - hw.I_dot_max)
  else
    QFixed.zero

/--
  D. Total Burn Defect
  Delta_burn = E_model + E_sensor + E_act
-/
def compute_total_burn_defect (hw : HardwareSpec) (receipt : BurnReceipt) (I_dot_req : QFixed) : QFixed :=
  receipt.eModel + hw.tau_sensor + compute_actuation_defect hw I_dot_req

/--
  Verify Ignition: The core FUS-1 Affordability Gate.
  Check metadata, Lawson criterion, and affordability.
-/
def verifyIgnition (hw : HardwareSpec) (state : PlasmaState) (receipt : BurnReceipt) : VerifierResult :=
  -- 1. Metadata/Envelope Check
  if hw.canon_profile_hash ≠ CANON_PROFILE_HASH_DEMO then
    VerifierResult.reject_invalid_envelope s!"REJECT_INVALID_ENVELOPE: Profile hash mismatch. Expected {CANON_PROFILE_HASH_DEMO}, got {hw.canon_profile_hash}"

  -- 2. Lawson Criterion Check (beta * density * temperature >= 100)
  else if state.beta * state.density * state.temperature < QFixed.fromInt 100 then
    VerifierResult.reject_unauthorized_transition "REJECT_UNAUTHORIZED_TRANSITION: Plasma state does not satisfy Lawson criterion."

  -- 3. Affordability Gate
  else
    let d_active := compute_delta_active state.beta
    let i_req := compute_I_dot_req d_active
    let total_defect := compute_total_burn_defect hw receipt i_req
    let authority := receipt.etaAvailable * receipt.dt

    if total_defect > authority then
      VerifierResult.reject_unaffordable_burn s!"REJECT_UNAFFORDABLE_BURN: Total defect ({total_defect.toFloat} ms) exceeds available boundary layer Lyapunov descent ({authority.toFloat} ms). Actuator slew rate insufficient (Required: {i_req.toFloat} A/ms, Available: {hw.I_dot_max.toFloat} A/ms)."
    else
      VerifierResult.accept

end CohFusion.Control.Burn
