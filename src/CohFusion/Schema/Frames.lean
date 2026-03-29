import Lean.Data.Json
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize

namespace CohFusion.Schema

/-!
# Dataset Frame Structures for Coh-Fusion

This module defines the Lean structures corresponding to the 6 tokamak fusion datasets
plus the master FusionJoinedFrame.

## Dataset 01: Geometry, Position, and Shape
Maps to: State6.Z, State6.vZ
!-/

open CohFusion.Numeric

/-- Dataset 01: Geometry, Position, and Shape.
    Maps to State6.Z (vertical position), State6.vZ (vertical velocity). -/
structure FusionGeometryFrame where
  shot_id             : String
  t_ms                : QFixed
  ip_ma               : QFixed
  bt_t                : QFixed
  r_geo_m             : QFixed
  z_geo_m             : QFixed
  r_axis_m            : QFixed
  z_axis_m            : QFixed
  kappa               : QFixed
  delta_upper         : QFixed
  delta_lower         : QFixed
  area_m2             : QFixed
  volume_m3           : QFixed
  q95                 : QFixed
  li_3                : QFixed
  beta_n              : QFixed
  shape_error_rms      : QFixed
  vertical_margin     : QFixed
  equilibrium_status : String -- "good" | "warning" | "bad"
  -- Strongly recommended
  x_point_r_m          : Option QFixed := none
  x_point_z_m         : Option QFixed := none
  strike_point_in_r_m : Option QFixed := none
  strike_point_out_r_m: Option QFixed := none
  boundary_gap_min_m  : Option QFixed := none
  wall_clearance_min_m  : Option QFixed := none
  locked_mode_amp_g    : Option QFixed := none
  halo_current_ka    : Option QFixed := none
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Dataset 02: Stability and MHD Risk.
    Maps to State6.W (tearing width proxy), State6.vW (tearing growth-rate). -/
structure FusionStabilityFrame where
  shot_id                  : String
  t_ms                    : QFixed
  q95                     : QFixed
  li_3                    : QFixed
  beta_n                   : QFixed
  density_frac_greenwald   : QFixed
  locked_mode_amp          : QFixed
  mhd_activity_rms         : QFixed
  mirnov_bandpower_low     : QFixed
  mirnov_bandpower_mid    : QFixed
  mirnov_bandpower_high    : QFixed
  tearing_risk_score       : QFixed
  disruption_risk_score   : QFixed
  vertical_event_risk_score: QFixed
  radiated_power_frac      : QFixed
  confinement_mode        : String -- "L" | "H" | "I" | "unknown"
  -- Strongly recommended
  rotation_core_krad_s     : Option QFixed := none
  rotation_edge_krad_s     : Option QFixed := none
  ntm_amplitude           : Option QFixed := none
  island_width_est_m     : Option QFixed := none
  elm_activity_score     : Option QFixed := none
  dwdt_proxy             : Option QFixed := none
  runaway_risk_score     : Option QFixed := none
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Dataset 03: Kinetic and Profile Summary.
    For supervisory control, not real-time State6. -/
structure FusionProfileFrame where
  shot_id                    : String
  t_ms                      : QFixed
  ne_line_1e19_m3           : QFixed
  te_core_kev                : QFixed
  te_edge_kev                : QFixed
  ti_core_kev               : QFixed
  stored_energy_mj            : QFixed
  pressure_norm             : QFixed
  current_profile_peaking     : QFixed
  density_peaking           : QFixed
  temperature_peaking       : QFixed
  confinement_quality_score : QFixed
  -- Strongly recommended
  pedestal_height_kev       : Option QFixed := none
  pedestal_width_norm       : Option QFixed := none
  bootstrap_fraction        : Option QFixed := none
  zeff                    : Option QFixed := none
  impurity_radiation_score  : Option QFixed := none
  fast_ion_pressure_norm  : Option QFixed := none
  runaway_seed_indicator   : Option QFixed := none
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Dataset 04: Actuator Commands, Availability, and Health.
    Maps to State6.I_act (active vertical-control actuator), State6.I_cd (current-drive). -/
structure FusionActuatorFrame where
  shot_id                  : String
  t_ms                    : QFixed
  pf_req_vector           : String -- JSON array of QFixed
  pf_meas_vector        : String -- JSON array of QFixed
  pf_slew_margin         : QFixed
  pf_saturation_flag    : Bool
  fuel_req               : QFixed
  fuel_meas              : QFixed
  heat_req_mw             : QFixed
  heat_meas_mw            : QFixed
  current_drive_req_mw    : QFixed
  current_drive_meas_mw   : QFixed
  actuator_delay_ms       : QFixed
  actuator_health_status : String -- "good" | "degraded" | "unavailable"
  -- Strongly recommended
  nbi_available           : Option Bool := none
  ech_available          : Option Bool := none
  icrh_available         : Option Bool := none
  gas_valve_available    : Option Bool := none
  current_drive_slew_margin : Option QFixed := none
  heating_slew_margin    : Option QFixed := none
  allocation_mode        : Option String := none
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Dataset 05: Event Labels and Prediction Horizons.
    Training/evaluation only, not real-time control. -/
structure FusionEventLabelFrame where
  shot_id                  : String
  t_ms                    : QFixed
  safe_state_label         : Bool
  disruption_in_10ms       : Option Bool := none
  disruption_in_50ms       : Option Bool := none
  disruption_in_100ms      : Option Bool := none
  rampdown_start_in_50ms  : Option Bool := none
  locked_mode_onset_in_20ms : Option Bool := none
  tearing_onset_in_20ms   : Option Bool := none
  vde_onset_in_10ms        : Option Bool := none
  time_to_disruption_ms    : Option QFixed := none
  time_to_rampdown_ms      : Option QFixed := none
  -- Strongly recommended
  event_source            : Option String := none -- "human" | "rule-based" | "benchmark"
  label_confidence        : Option QFixed := none
  false_alarm_cost_weight : Option QFixed := none
  missed_alarm_cost_weight : Option QFixed := none
  operating_phase        : Option String := none -- "startup" | "flat_top" | "transition" | "rampdown" | "shutdown"
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Dataset 06: Data Quality, Uncertainty, and Defect Channels.
    Maps to defect components for verification decision. -/
structure FusionQualityFrame where
  shot_id                    : String
  t_ms                      : QFixed
  magnetic_data_freshness_ms : QFixed
  profile_data_freshness_ms  : QFixed
  missing_core_signal_count  : Nat
  stale_signal_count       : Nat
  equilibrium_residual_norm: QFixed
  sensor_confidence_score   : QFixed
  estimator_confidence_score: QFixed
  model_defect_est        : QFixed
  actuation_defect_est    : QFixed
  sensing_defect_est      : QFixed
  total_defect_est         : QFixed
  data_quality_status    : String -- "good" | "warning" | "bad"
  -- Strongly recommended
  time_sync_error_ms       : Option QFixed := none
  confidence_floor_triggered: Option Bool := none
  estimator_version       : Option String := none
  predictor_version       : Option String := none
  calibration_regime_id   : Option String := none
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Master joined frame: combines all 6 datasets.
    Primary join key: shot_id + t_ms -/
structure FusionJoinedFrame where
  shot_id              : String
  t_ms                 : QFixed
  regime_id            : Option String := none
  controller_cycle_id  : Option Nat    := none
  predictor_version    : Option String := none
  estimator_version   : Option String := none
  certificate_id       : Option String := none
  geometry             : Option FusionGeometryFrame := none
  stability            : Option FusionStabilityFrame := none
  kinetic              : Option FusionProfileFrame := none
  actuator             : Option FusionActuatorFrame := none
  labels               : Option FusionEventLabelFrame := none
  quality              : Option FusionQualityFrame := none
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

end CohFusion.Schema
