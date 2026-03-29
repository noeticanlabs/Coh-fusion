import CohFusion.Schema.Frames
import CohFusion.Core.State
import CohFusion.Product.HardwareCertificate
import CohFusion.Numeric.QFixed

namespace CohFusion.Schema

/-!
# Adapters: FusionJoinedFrame to Coh-Fusion Types

This module implements the transformations from FusionJoinedFrame to:
- State6 (minimal real-time verifier state)
- AuthorityBudget (authority evaluation result)
- DefectBundle (defect pricing result)

## State Estimation (Stage 2)
FusionJoinedFrame → State6 α

## Authority Evaluation (Stage 4)
FusionJoinedFrame × HardwareCertificate → AuthorityBudget

## Defect Pricing (Stage 5)
FusionJoinedFrame × DefectPolicy → DefectBundle
!-/

open CohFusion.Numeric
open CohFusion.Core

/-- AuthorityBudget: result of authority evaluation (Stage 4).

    Computed from:
    - Dataset 04 (Actuator) available authority
    - HardwareCertificate limits -/
structure AuthorityBudget where
  available_slew      : QFixed -- remaining slew authority
  available_position  : QFixed -- remaining position authority
  available_authority : QFixed -- min(available_slew, available_position)
  authority_margin   : QFixed -- available_authority - requested_action
  latency_measured    : QFixed -- actual actuator delay
  latency_vs_cert     : QFixed -- measured - certified latency
  is_degraded         : Bool   -- health_status = "degraded"
  is_unavailable      : Bool   -- health_status = "unavailable"
  deriving Repr, Inhabited

/-- DefectBundle: defect pricing components (Stage 5).

    Components from Dataset 06:
    - model_defect: model-side defect (prediction uncertainty)
    - actuation_defect: actuation-side defect (actuator drift/gap)
    - sensing_defect: sensor/observation defect (measurement noise/bias)
    - total_defect: aggregate defect -/
structure DefectBundle where
  model_defect       : QFixed
  actuation_defect  : QFixed
  sensing_defect    : QFixed
  dominant_component: String -- "model" | "actuation" | "sensing"
  dominant_ratio    : QFixed -- dominant / total
  total_defect      : QFixed
  quality_multiplier: QFixed -- based on data_quality_status
  sensor_confidence : QFixed
  estimator_confidence: QFixed
  deriving Repr, Inhabited

/-- Extract vertical position Z from geometry frame.

    Maps: Dataset 01: z_axis_m → State6.Z -/
def extractZ (geo : FusionGeometryFrame) : QFixed :=
  geo.z_axis_m

/-- Extract vertical velocity vZ from geometry frame (requires previous frame).

    Maps: derived from z_axis_m change → State6.vZ
    Alternative: use Dataset 02 dwdt_proxy -/
def extractVZ (geo_current : FusionGeometryFrame) (geo_prev : FusionGeometryFrame) : QFixed :=
  let dt := geo_current.t_ms - geo_prev.t_ms
  (geo_current.z_axis_m - geo_prev.z_axis_m) / dt

/-- Extract tearing width proxy W from stability frame.

    Maps: Dataset 02: tearing_risk_score normalized → State6.W -/
def extractW (stab : FusionStabilityFrame) : QFixed :=
  stab.tearing_risk_score

/-- Extract tearing growth rate vW from stability frame.

    Maps: Dataset 02: dwdt_proxy → State6.vW -/
def extractVW (stab : FusionStabilityFrame) : QFixed :=
  match stab.dwdt_proxy with
  | some dwdt => dwdt
  | none => QFixed.zero -- Default if not available

/-- Extract active actuator state I_act from actuator frame.

    Maps: Dataset 04: pf_meas_vector → State6.I_act
    Uses vertical control component -/
def extractIAct (act : FusionActuatorFrame) : QFixed :=
  -- In practice, parse pf_meas_vector JSON and extract vertical component
  -- For now, use pf_slew_margin as proxy for available authority
  act.pf_slew_margin

/-- Extract current-drive state I_cd from actuator frame.

    Maps: Dataset 04: current_drive_meas_mw → State6.I_cd -/
def extractICd (act : FusionActuatorFrame) : QFixed :=
  act.current_drive_meas_mw

/-- Estimate State6 from FusionJoinedFrame.

    This implements the Stage 2: Estimate State transformation.

    Returns none if critical fields are missing -/
def estimateState6 (frame : FusionJoinedFrame) : Option (State6 QFixed) :=
  do
    let geo ← frame.geometry
    let stab ← frame.stability
    let act ← frame.actuator

    let z ← some geo.z_axis_m
    let vZ ← QFixed.zero -- Note: requires temporal context, simplified
    let i_act ← extractIAct act
    let w ← extractW stab
    let vW ← extractVW stab
    let i_cd ← extractICd act

    some { Z := z, vZ := vZ, I_act := i_act, W := w, vW := vW, I_cd := i_cd }

/-- Evaluate authority budget from FusionJoinedFrame and HardwareCertificate.

    This implements the Stage 4: Evaluate Authority transformation.

    Computes:
    - available authority = min(cert.slew_limit - current, cert.saturation_limit - position)
    - authority margin = available - requested -/
def evaluateAuthority
    (frame : FusionJoinedFrame)
    (cert : HardwareCertificate)
    : AuthorityBudget :=
  let act := frame.actuator.getD defaultActuator
  let requested := act.pf_slew_margin
  let available := cert.slew_limit

  let available_slew := available - requested
  let available_position := cert.saturation_limit -- Simplified
  let authority_margin := min available_slew available_position - requested

  let is_degraded := act.actuator_health_status == "degraded"
  let is_unavailable := act.actuator_health_status == "unavailable"

  {
    available_slew := available_slew,
    available_position := available_position,
    available_authority := min available_slew available_position,
    authority_margin := authority_margin,
    latency_measured := act.actuator_delay_ms,
    latency_vs_cert := act.actuator_delay_ms - cert.latency,
    is_degraded := is_degraded,
    is_unavailable := is_unavailable
  }
where
  defaultActuator : FusionActuatorFrame :=
    { shot_id := "", t_ms := QFixed.zero,
      pf_req_vector := "[]", pf_meas_vector := "[]",
      pf_slew_margin := QFixed.zero, pf_saturation_flag := false,
      fuel_req := QFixed.zero, fuel_meas := QFixed.zero,
      heat_req_mw := QFixed.zero, heat_meas_mw := QFixed.zero,
      current_drive_req_mw := QFixed.zero, current_drive_meas_mw := QFixed.zero,
      actuator_delay_ms := QFixed.zero, actuator_health_status := "good" }

/-- Price defect components from FusionJoinedFrame.

    This implements the Stage 5: Price Defect transformation.

    Extracts from Dataset 06:
    - model defect
    - actuation defect
    - sensing defect
    - applies quality multiplier -/
def priceDefect (frame : FusionJoinedFrame) : DefectBundle :=
  let qual := frame.quality.getD defaultQuality

  let model_def := qual.model_defect_est
  let act_def := qual.actuation_defect_est
  let sens_def := qual.sensing_defect_est

  -- Determine dominant component
  let (dominant, ratio) :=
    if model_def >= act_def && model_def >= sens_def then
      ("model", model_def / qual.total_defect_est)
    else if act_def >= model_def && act_def >= sens_def then
      ("actuation", act_def / qual.total_defect_est)
    else
      ("sensing", sens_def / qual.total_defect_est)

  -- Quality multiplier
  let quality_mult :=
    match qual.data_quality_status with
    | "good" => QFixed.one
    | "warning" => QFixed.ofNat 75 / QFixed.ofNat 50 -- 1.5x
    | "bad" => QFixed.ofNat 2 -- 2.0x
    | _ => QFixed.one

  {
    model_defect := model_def,
    actuation_defect := act_def,
    sensing_defect := sens_def,
    dominant_component := dominant,
    dominant_ratio := ratio,
    total_defect := qual.total_defect_est,
    quality_multiplier := quality_mult,
    sensor_confidence := qual.sensor_confidence_score,
    estimator_confidence := qual.estimator_confidence_score
  }
where
  defaultQuality : FusionQualityFrame :=
    { shot_id := "", t_ms := QFixed.zero,
      magnetic_data_freshness_ms := QFixed.zero,
      profile_data_freshness_ms := QFixed.zero,
      missing_core_signal_count := 0,
      stale_signal_count := 0,
      equilibrium_residual_norm := QFixed.zero,
      sensor_confidence_score := QFixed.one,
      estimator_confidence_score := QFixed.one,
      model_defect_est := QFixed.zero,
      actuation_defect_est := QFixed.zero,
      sensing_defect_est := QFixed.zero,
      total_defect_est := QFixed.zero,
      data_quality_status := "good" }

/-- Check if a frame has sufficient data quality for processing.

    Returns false if quality is "bad" or critical signals are stale/missing. -/
def hasValidQuality (frame : FusionJoinedFrame) : Bool :=
  match frame.quality with
  | some q =>
    q.data_quality_status != "bad" &&
    q.missing_core_signal_count == 0 &&
    q.stale_signal_count == 0
  | none => false

/-- Check if geometry frame is valid for state estimation.

    Rejects if:
    - missing z_axis_m
    - equilibrium_status != "good" -/
def hasValidGeometry (frame : FusionJoinedFrame) : Bool :=
  match frame.geometry with
  | some g =>
    g.equilibrium_status == "good"
  | none => false

end CohFusion.Schema
