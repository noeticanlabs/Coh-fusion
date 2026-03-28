import CohFusion
import CohFusion.Control.BurnContract
import CohFusion.Control.BurnPolicyDemo
import CohFusion.Product.HardwareCertificate
import CohFusion.Numeric.QFixed
import CohFusion.Crypto.Ledger
import Lean.Data.Json

open CohFusion.Control.BurnContract
open CohFusion.Control.BurnPolicyDemo
open CohFusion.Product
open CohFusion.Numeric
open CohFusion.Crypto.Ledger
open Lean

def main (args : List String) : IO Unit := do
  -- Automated Ingestion (Standard Mode)
  let hwPath : System.FilePath := "test/data/hardware_spec_sparc.json"
  let statePath : System.FilePath := if args.contains "--fail" then "test/data/plasma_state_failing.json" else "test/data/plasma_state_high_beta.json"

  if (← hwPath.pathExists) && (← statePath.pathExists) then
    let stateFile ← IO.FS.readFile statePath
    let stateJson ← IO.ofExcept (Json.parse stateFile)

    -- In the new staged pipeline, we use the typed HardwareCertificate
    -- Note: We map the old JSON schema to the new typed object manually or via a new instance
    let cert : HardwareCertificate := {
      certificate_id := "cert_demo",
      hardware_id := "hw_demo",
      latency := QFixed.fromFloat 0.005,
      observation_error := QFixed.fromFloat 0.001,
      slew_limit := QFixed.fromFloat 200.0,
      saturation_limit := QFixed.fromFloat 1000.0,
      operating_regime_hash := "sha256:demo",
      calibration_epoch := "2026-03-28",
      expiry := "2027-01-01",
      root_of_trust := "coh_root",
      signature := "sig"
    }

    let plasmaState : PlasmaState ← IO.ofExcept (fromJson? stateJson)

    let prev_digest := "0000000000000000000000000000000000000000000000000000000000000000"

    IO.println "=== Coh-Fusion Integrated Operational Spine (v3 Pipeline) ==="
    IO.println s!"Auditing Cert ID: {cert.certificate_id}"

    match verifyIgnition_v3 cert plasmaState (QFixed.one) (QFixed.fromFloat 50.0) prev_digest with
    | VerifierResult.reject_unaffordable_burn reason =>
        IO.println s!"VERIFIER_RESULT: REJECT\nReason: {reason}"
    | VerifierResult.reject_invalid_envelope reason =>
        IO.println s!"VERIFIER_RESULT: REJECT\nReason: {reason}"
    | VerifierResult.reject_unauthorized_transition reason =>
        IO.println s!"VERIFIER_RESULT: REJECT\nReason: {reason}"
    | VerifierResult.reject_threshold_exceeded reason =>
        IO.println s!"VERIFIER_RESULT: REJECT\nReason: {reason}"
    | VerifierResult.accept receipt digest =>
        IO.println "VERIFIER_RESULT: ACCEPT"
        IO.println s!"Chain Digest: {digest}"

        -- Write the cryptographic artifact to disk
        let out_path := "test/data/receipt_out.json"
        IO.FS.writeFile out_path (toString (toJson receipt))
        IO.println s!"Cryptographic BurnReceipt written to {out_path}"
  else
    IO.println "Error: Test data not found in test/data/."
