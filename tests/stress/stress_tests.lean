import CohFusion.Product.CommercialWedge
import CohFusion.Product.HardwareCertificate
import CohFusion.Numeric.QFixed

/-!
# Stress Tests: Edge Cases from test/data/

This test suite uses the JSON fixtures from test/data/ to verify
the wedge handles edge cases correctly:
- plasma_state_high_beta.json - high plasma pressure
- plasma_state_failing.json - failing stability bounds
- hardware_spec_sparc.json - hardware limits

Used for funding demonstrations and validation.
-/

namespace Tests.Stress

open CohFusion.Product
open CohFusion.Numeric

/-- SPARC hardware limits from JSON fixture -/
def sparcHardware : HardwareCertificate :=
  { certificate_id := "CERT-SPARC-2026-A",
    hardware_id := "SPARC-001",
    latency := ⟨2000000⟩,          -- tau_sensor = 0.002s
    observation_error := ⟨1844674407370955⟩,
    slew_limit := ⟨200000000000⟩,  -- I_dot_max = 200.0
    saturation_limit := ⟨50000000000000⟩,  -- I_max = 50000.0
    operating_regime_hash := "a1b2c3d4...",
    calibration_epoch := "2026-01-01",
    expiry := "2027-12-31",
    root_of_trust := "sparc-root",
    signature := "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6" }

/-- Test risk params -/
def stressParams : CohFusion.Geometry.ParamsFus QFixed :=
  { vde := { omega1 := QFixed.one, omega2 := QFixed.one, omega3 := QFixed.one,
            Z_wall := ⟨5000000000000⟩, -- 5m wall
            delta_safe := ⟨100000000000⟩,  -- 0.1m safe margin
            Theta_V := ⟨10000000000000⟩ }, -- threshold
    tear := { nu1 := QFixed.one, nu2 := QFixed.one, nu3 := QFixed.one,
             W_crit := ⟨500000000⟩,  -- 0.5m critical width
             Theta_T := ⟨10000000000000⟩ } }

/-!
## Stress Test 1: High Beta Plasma

Corresponds to plasma_state_high_beta.json:
- beta = 0.048 (elevated)
- I_p = 1.2 MA

Expected: Advisory mode should warn but not reject
-/
#eval do
  let wedge : CommercialWedge :=
    { mode := DeploymentMode.advisory,
      certificate := sparcHardware,
      risk_params := stressParams,
      threshold := stressParams.vde.Theta_V,
      defect_limit := ⟨50000000000⟩,
      gamma_oplax := ⟨0⟩,
      regime_id := "sparc-regime" }

  -- High beta state: elevated I_act simulates high plasma current
  let state : CohFusion.Product.ObservableChannels :=
    { vde_displacement := ⟨100000000⟩,  -- 0.1m from wall
      vde_velocity := ⟨500000000⟩,
      vde_actuator := ⟨1200000000000⟩,  -- 1.2 MA → high actuator
      tear_width := ⟨100000000⟩,       -- elevated width
      tear_growth := ⟨50000000⟩,
      tear_actuator := ⟨0⟩ }

  let next := state  -- no change yet
  let spend := ⟨1000000000000⟩  -- reasonable spend
  let defect := ⟨100000000000⟩   -- bounded defect

  let result := CohFusion.Product.evaluateTransition wedge state next spend defect
  match result with
  | WedgeDecision.allow =>
    IO.println "Stress 1 (high_beta): PASS - allow"
  | WedgeDecision.warn msg =>
    IO.println s!"Stress 1 (high_beta): WARN - {msg}"
  | WedgeDecision.reject _ msg =>
    IO.println s!"Stress 1 (high_beta): REJECT - {msg}"
  pure ()

/-!
## Stress Test 2: Hardware Saturation

Push actuator to I_max limit (50000 A) from JSON fixture
Expected: Should accept within bounds, reject if exceeded
-/
#eval do
  let wedge : CommercialWedge :=
    { mode := DeploymentMode.hard_gate,
      certificate := sparcHardware,
      risk_params := stressParams,
      threshold := stressParams.vde.Theta_V,
      defect_limit := ⟨50000000000⟩,
      gamma_oplax := ⟨0⟩,
      regime_id := "sparc-regime" }

  -- At saturation limit
  let state : CohFusion.Product.ObservableChannels :=
    { vde_displacement := ⟨0⟩, vde_velocity := ⟨0⟩,
      vde_actuator := ⟨50000000000000⟩,  -- I_max from JSON: 50000.0
      tear_width := ⟨0⟩, tear_growth := ⟨0⟩, tear_actuator := ⟨0⟩ }

  let next := state
  let spend := ⟨2500000000000000⟩  -- u²*dt at saturation
  let defect := ⟨0⟩

  let result := CohFusion.Product.evaluateTransition wedge state next spend defect
  match result with
  | WedgeDecision.allow =>
    IO.println "Stress 2 (saturation @ I_max): PASS - allow"
  | _ =>
    IO.println s!"Stress 2 (saturation): WARN/REJECT - {repr result}"
  pure ()

/-!
## Stress Test 3: Above Hardware Limit

Exceed I_max to trigger hardware rejection
-/
#eval do
  let wedge : CommercialWedge :=
    { mode := DeploymentMode.hard_gate,
      certificate := sparcHardware,
      risk_params := stressParams,
      threshold := stressParams.vde.Theta_V,
      defect_limit := ⟨50000000000⟩,
      gamma_oplax := ⟨0⟩,
      regime_id := "sparc-regime" }

  -- Exceed saturation limit
  let state : CohFusion.Product.ObservableChannels :=
    { vde_displacement := ⟨0⟩, vde_velocity := ⟨0⟩,
      vde_actuator := ⟨60000000000000⟩,  -- 60000 > 50000 I_max!
      tear_width := ⟨0⟩, tear_growth := ⟨0⟩, tear_actuator := ⟨0⟩ }

  let next := state
  let spend := ⟨3600000000000000⟩
  let defect := ⟨0⟩

  let result := CohFusion.Product.evaluateTransition wedge state next spend defect
  match result with
  | WedgeDecision.allow =>
    IO.println "Stress 3 ( > I_max): FAIL - should reject"
  | _ =>
    IO.println s!"Stress 3 ( > I_max): PASS - {repr result}"
  pure ()

/-!
## Stress Test 4: High Slew Rate

Push I_dot to I_dot_max from JSON (200 A/μs)
Expected: Accept just at limit
-/
#eval do
  let wedge : CommercialWedge :=
    { mode := DeploymentMode.replay,
      certificate := sparcHardware,
      risk_params := stressParams,
      threshold := stressParams.vde.Theta_V,
      defect_limit := ⟨50000000000⟩,
      gamma_oplax := ⟨0⟩,
      regime_id := "sparc-regime" }

  -- At slew limit: rapid current change
  let state : CohFusion.Product.ObservableChannels :=
    { vde_displacement := ⟨0⟩,
      vde_velocity := ⟨200000000000⟩,  -- 200 A/μs = I_dot_max
      vde_actuator := ⟨10000000000000⟩,
      tear_width := ⟨0⟩, tear_growth := ⟨0⟩, tear_actuator := ⟨0⟩ }

  let next := state
  let spend := ⟨40000000000000⟩  -- high control effort
  let defect := ⟨0⟩

  let result := CohFusion.Product.evaluateTransition wedge state next spend defect
  match result with
  | WedgeDecision.allow =>
    IO.println "Stress 4 ( @ I_dot_max): PASS - allow"
  | _ =>
    IO.println s!"Stress 4 ( @ I_dot_max): WARN/REJECT - {repr result}"
  pure ()

/-!
## Stress Test 5: Sensor Latency Boundary

Operate at tau_sensor = 2ms latency boundary
This is below the time scale of plasma dynamics
-/
#eval do
  let wedge : CommercialWedge :=
    { mode := DeploymentMode.shadow,
      certificate := sparcHardware,
      risk_params := stressParams,
      threshold := stressParams.vde.Theta_V,
      defect_limit := ⟨50000000000⟩,
      gamma_oplax := ⟨0⟩,
      regime_id := "sparc-regime" }

  -- Quick dynamics: within sensor latency
  let state : CohFusion.Product.ObservableChannels :=
    { vde_displacement := ⟨2000000000⟩,  -- 2m, approaching wall
      vde_velocity := ⟨100000000000⟩,  -- fast
      vde_actuator := ⟨2000000000000⟩,
      tear_width := ⟨300000000⟩,  -- approaching critical
      tear_growth := ⟨100000000⟩,
      tear_actuator := ⟨5000000000⟩ }

  let next := state
  let spend := ⟨100000000000000⟩
  let defect := ⟨5000000000⟩

  let result := CohFusion.Product.evaluateTransition wedge state next spend defect
  match result with
  | WedgeDecision.allow =>
    IO.println "Stress 5 ( @ tau_sensor): PASS - allow"
  | WedgeDecision.warn msg =>
    IO.println s!"Stress 5 ( @ tau_sensor): WARN - {msg}"
  | WedgeDecision.reject _ msg =>
    IO.println s!"Stress 5 ( @ tau_sensor): REJECT - {msg}"
  pure ()

/-!
## Stress Test 6: Tearing Mode Stability Boundary

At W_crit (critical width), should warn but accept
-/
#eval do
  let wedge : CommercialWedge :=
    { mode := DeploymentMode.advisory,
      certificate := sparcHardware,
      risk_params := stressParams,
      threshold := stressParams.tear.Theta_T,
      defect_limit := ⟨50000000000⟩,
      gamma_oplax := ⟨0⟩,
      regime_id := "sparc-regime" }

  -- At critical tearing width
  let state : CohFusion.Product.ObservableChannels :=
    { vde_displacement := ⟨0⟩, vde_velocity := ⟨0⟩, vde_actuator := ⟨0⟩,
      tear_width := ⟨500000000⟩,  -- W_crit = 0.5m
      tear_growth := ⟨0⟩,
      tear_actuator := ⟨0⟩ }

  let next := state
  let spend := ⟨1000000000000⟩
  let defect := ⟨0⟩

  let result := CohFusion.Product.evaluateTransition wedge state next spend defect
  match result with
  | WedgeDecision.allow =>
    IO.println "Stress 6 ( @ W_crit): PASS - allow"
  | _ =>
    IO.println s!"Stress 6 ( @ W_crit): WARN/REJECT - {repr result}"
  pure ()

end Tests.Stress
