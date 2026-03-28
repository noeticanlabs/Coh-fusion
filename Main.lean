import CohFusion
import CohFusion.Control.Burn
import CohFusion.Numeric.QFixed
import CohFusion.Crypto.Ledger
import Lean.Data.Json

open CohFusion.Control.Burn
open CohFusion.Numeric
open CohFusion.Crypto.Ledger
open Lean

def main (args : List String) : IO Unit := do
  -- Automated Ingestion (Standard Mode)
  let hwPath : System.FilePath := "test/data/hardware_spec_sparc.json"
  let statePath : System.FilePath := if args.contains "--fail" then "test/data/plasma_state_failing.json" else "test/data/plasma_state_high_beta.json"

  if (← hwPath.pathExists) && (← statePath.pathExists) then
    let hwFile ← IO.FS.readFile hwPath
    let stateFile ← IO.FS.readFile statePath

    let hwJson ← IO.ofExcept (Json.parse hwFile)
    let stateJson ← IO.ofExcept (Json.parse stateFile)

    let hwSpec : HardwareSpec ← IO.ofExcept (fromJson? hwJson)
    let plasmaState : PlasmaState ← IO.ofExcept (fromJson? stateJson)

    let prev_digest := "0000000000000000000000000000000000000000000000000000000000000000"

    IO.println "=== Coh-Fusion Integrated Operational Spine ==="
    IO.println s!"Auditing Cert ID: {hwSpec.cert_id}"

    match verifyIgnition_v2 hwSpec plasmaState (QFixed.one) (QFixed.fromFloat 50.0) prev_digest with
    | VerifierResult.reject_unaffordable_burn reason =>
        IO.println s!"VERIFIER_RESULT: REJECT\nReason: {reason}"
    | VerifierResult.reject_invalid_envelope reason =>
        IO.println s!"VERIFIER_RESULT: REJECT\nReason: {reason}"
    | VerifierResult.reject_unauthorized_transition reason =>
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
