import Lean.Data.Json
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize
import CohFusion.Geometry.VDE
import CohFusion.Geometry.Tearing
import CohFusion.Crypto.Ledger

namespace CohFusion.Control.Burn

open CohFusion.Numeric
open CohFusion.Crypto.Ledger

/--
  Hardware Specification mapping the commercial prototype JSON.
  Includes physical parameters and governance metadata.
-/
structure HardwareSpec where
  schema_id          : String
  cert_id            : String
  canon_profile_hash : String
  I_max              : QFixed
  I_dot_max          : QFixed
  tau_sensor         : QFixed
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Plasma state for burn verification. -/
structure PlasmaState where
  beta        : QFixed
  M_z         : QFixed  -- Vertical Current Moment
  I_p         : QFixed  -- Total Plasma Current
  Q_tilde     : QFixed  -- Signed Tearing Flux
  n_X         : QFixed  -- Certified Drift Norm ||z||_X
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Detailed result for the FUS-1 verifier. -/
inductive VerifierResult
  | accept (receipt : BurnReceipt) (digest : String)
  | reject_invalid_envelope (msg : String)
  | reject_unauthorized_transition (msg : String)
  | reject_unaffordable_burn (msg : String)
  deriving Repr

/-- Heuristic parameters for FUS-1. -/
def beta_ignite : QFixed := QFixed.fromFloat 0.05
def delta_0     : QFixed := QFixed.fromFloat 10.0
def delta_min   : QFixed := QFixed.fromFloat 0.1

/--
  Geometric Defect Calculation (Phase 1)
  Evaluate margins and compute actuation defect.
-/
def compute_geometric_defect (hw : HardwareSpec) (state : PlasmaState) : QFixed :=
  -- 1. True Geometric Margins
  let m_vde := CohFusion.Geometry.VDE.evaluate_margin state.M_z state.I_p (QFixed.fromFloat 2.5) -- Mock Z_max
  let m_tear := CohFusion.Geometry.Tearing.evaluate_margin state.Q_tilde (QFixed.fromFloat 0.8)  -- Mock Q_crit

  -- 2. Boundary Layer Shrinkage (The weakest margin dictates the active layer)
  let delta_active := if m_vde < m_tear then m_vde else m_tear

  -- 3. Slew Requirement & Actuation Defect
  if delta_active ≤ QFixed.zero then
    QFixed.fromInt 999999 -- Boundary breached, catastrophic defect
  else
    let C_slew := QFixed.fromFloat 50.0
    let I_dot_req := C_slew / (delta_active * delta_active)
    let lag_penalty := QFixed.fromFloat 2.5
    if I_dot_req > hw.I_dot_max then
      lag_penalty * (I_dot_req - hw.I_dot_max)
    else
      QFixed.zero

/--
  Core FUS-1 Ignition Verifier v2 (Phase 2)
  Geometry Docked + Crypto Bound.
-/
def verifyIgnition_v2 (hw : HardwareSpec) (state : PlasmaState) (dt : QFixed) (eta_avail : QFixed) (prev_digest : String) : VerifierResult :=
  let m_vde := CohFusion.Geometry.VDE.evaluate_margin state.M_z state.I_p (QFixed.fromFloat 2.5)
  let m_tear := CohFusion.Geometry.Tearing.evaluate_margin state.Q_tilde (QFixed.fromFloat 0.8)

  let E_act := compute_geometric_defect hw state
  let E_sensor := hw.tau_sensor * QFixed.fromFloat 100.0 -- Scaled latency penalty
  let delta_burn := E_act + E_sensor
  let authority := eta_avail * dt

  if delta_burn > authority then
    VerifierResult.reject_unaffordable_burn s!"REJECT_UNAFFORDABLE_BURN: Total defect ({delta_burn.toFloat}) exceeds available boundary layer Lyapunov descent ({authority.toFloat})."
  else
    let receipt : BurnReceipt := {
      k_index := 1,
      m_tear_hat := m_tear.toFloat,
      m_VDE_hat := m_vde.toFloat,
      m_I_hat := (state.I_p - QFixed.one).toFloat,
      n_X_hat := state.n_X.toFloat,
      L_R_hat := (state.n_X * QFixed.fromFloat 1.5).toFloat, -- Mock Lipschitz scaling
      E_time_hat := 0.01,
      E_quant_hat := 0.001,
      E_obs_hat := E_sensor.toFloat,
      E_model_hat := E_act.toFloat,
      state_digest := prev_digest
    }
    -- Create canonical JSON string of the receipt to hash
    let receipt_json_str := toString (Lean.toJson receipt)
    let new_digest := compute_sha256_mock receipt_json_str

    VerifierResult.accept receipt new_digest

end CohFusion.Control.Burn
