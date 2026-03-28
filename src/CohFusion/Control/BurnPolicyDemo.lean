import CohFusion.Control.BurnContract
import CohFusion.Geometry.VDERuntime
import CohFusion.Geometry.TearingRuntime
import CohFusion.Product.HardwareCertificate
import CohFusion.Crypto.Ledger

namespace CohFusion.Control.BurnPolicyDemo

open CohFusion.Numeric
open CohFusion.Product
open CohFusion.Control.BurnContract
open CohFusion.Crypto.Ledger

/-- Mock coefficients and thresholds for the demo. -/
def MOCK_Z_MAX : QFixed := QFixed.fromFloat 2.5
def MOCK_Q_CRIT : QFixed := QFixed.fromFloat 0.8
def MOCK_SLEW_CONSTANT : QFixed := QFixed.fromFloat 50.0
def MOCK_LAG_PENALTY : QFixed := QFixed.fromFloat 2.5
def MOCK_SENSOR_SCALE : QFixed := QFixed.fromFloat 100.0
def MOCK_LIPSCHITZ_SCALE : QFixed := QFixed.fromFloat 1.5

/-- Step 1: Evaluate observable margins. -/
def evaluateObservableMargins (state : PlasmaState) : ObservableMargins :=
  { m_vde  := CohFusion.Geometry.VDE.signed_runway_vde state.M_z state.I_p MOCK_Z_MAX,
    m_tear := CohFusion.Geometry.Tearing.signed_runway_tear state.Q_tilde MOCK_Q_CRIT }

/-- Step 2: Compute burn defect. -/
def computeBurnDefect (cert : HardwareCertificate) (_state : PlasmaState) (margins : ObservableMargins) : QFixed :=
  let delta_active := if margins.m_vde < margins.m_tear then margins.m_vde else margins.m_tear

  let E_act := if delta_active ≤ QFixed.zero then
    QFixed.fromInt 999999 -- Boundary breached
  else
    let I_dot_req := MOCK_SLEW_CONSTANT / (delta_active * delta_active)
    if I_dot_req > cert.slew_limit then
      MOCK_LAG_PENALTY * (I_dot_req - cert.slew_limit)
    else
      QFixed.zero

  let E_sensor := cert.latency * MOCK_SENSOR_SCALE
  E_act + E_sensor

/-- Step 3: Check affordability. -/
def checkAffordability (defect : QFixed) (authority : QFixed) : Bool :=
  defect ≤ authority

/-- Step 4: Build burn receipt. -/
def buildBurnReceipt (state : PlasmaState) (margins : ObservableMargins) (E_act : QFixed) (E_sensor : QFixed) (prev_digest : String) : BurnReceipt :=
  { k_index := 1,
    m_tear_hat := margins.m_tear.toFloat,
    m_VDE_hat := margins.m_vde.toFloat,
    m_I_hat := (state.I_p - QFixed.one).toFloat,
    n_X_hat := state.n_X.toFloat,
    L_R_hat := (state.n_X * MOCK_LIPSCHITZ_SCALE).toFloat,
    E_time_hat := 0.01,
    E_quant_hat := 0.001,
    E_obs_hat := E_sensor.toFloat,
    E_model_hat := E_act.toFloat,
    state_digest := prev_digest }

/-- Step 5: Bind receipt digest. -/
def bindReceiptDigest (receipt : BurnReceipt) : String :=
  compute_sha256_mock (toString (Lean.toJson receipt))

/--
  Integrated verifyIgnition (v3) using the staged pipeline.
-/
def verifyIgnition_v3
    (cert : HardwareCertificate)
    (state : PlasmaState)
    (dt : QFixed)
    (eta_avail : QFixed)
    (prev_digest : String)
    : VerifierResult :=
  let margins := evaluateObservableMargins state
  let E_burn := computeBurnDefect cert state margins
  let authority := eta_avail * dt

  if ¬(checkAffordability E_burn authority) then
    VerifierResult.reject_unaffordable_burn s!"REJECT_UNAFFORDABLE_BURN: Total defect ({E_burn.toFloat}) exceeds authority ({authority.toFloat})."
  else
    let receipt := buildBurnReceipt state margins E_burn (cert.latency * MOCK_SENSOR_SCALE) prev_digest
    let digest := bindReceiptDigest receipt
    VerifierResult.accept receipt digest

end CohFusion.Control.BurnPolicyDemo
