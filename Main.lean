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

    -- Get today's date for validation (in real system, get from system clock)
    let today := "2026-03-28"
    let expectedRegimeHash := "sha256:demo"

    -- Parse hardware certificate from JSON file
    let hwFile ← IO.FS.readFile hwPath
    let hwJson ← IO.ofExcept (Json.parse hwFile)
    let certRaw : HardwareCertificate ← IO.ofExcept (fromJson? hwJson)

    -- Validate certificate (reject expired/mismatched certs)
    let validatedCert ←
      match validateCertificate today expectedRegimeHash certRaw with
      | Except.error err =>
        IO.println s!"CERTIFICATE_VALIDATION_FAILED: {err}"
        pure none
      | Except.ok vc =>
        IO.println s!"Certificate {vc.cert.certificate_id} validated successfully"
        pure (some vc)

    let cert ←
      match validatedCert with
      | none => panic! "Invalid certificate"
      | some validated => validated.cert

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
