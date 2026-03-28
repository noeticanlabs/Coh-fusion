import CohFusion
import CohFusion.Control.Burn
import CohFusion.Numeric.QFixed
import Lean.Data.Json

open CohFusion.Control.Burn
open CohFusion.Numeric

def main : IO Unit := do
  -- 1. Ingest Hardware Certificate
  let hw_json_path : System.FilePath := "hardware_certificate.json"
  if ← hw_json_path.pathExists then
    let hw_json_content ← IO.FS.readFile hw_json_path
    let hw_json ← match Lean.Json.parse hw_json_content with
      | Except.ok j => pure j
      | Except.error e =>
        IO.println s!"REJECT_INVALID_ENVELOPE: Hardware JSON parse error: {e}"
        return

    let hw_spec : HardwareSpec ← match Lean.fromJson? hw_json with
      | Except.ok (s : HardwareSpec) => pure s
      | Except.error e =>
        IO.println s!"REJECT_INVALID_ENVELOPE: Hardware schema mismatch: {e}"
        return

    -- 2. Ingest Plasma State
    let state_json_path : System.FilePath := "plasma_state.json"
    if ← state_json_path.pathExists then
      let state_json_content ← IO.FS.readFile state_json_path
      let state_json ← match Lean.Json.parse state_json_content with
        | Except.ok j => pure j
        | Except.error e =>
          IO.println s!"REJECT_INVALID_ENVELOPE: Plasma State JSON parse error: {e}"
          return

      let plasma_state : PlasmaState ← match Lean.fromJson? state_json with
        | Except.ok (s : PlasmaState) => pure s
        | Except.error e =>
          IO.println s!"REJECT_INVALID_ENVELOPE: Plasma State schema mismatch: {e}"
          return

      -- 3. Ingest Burn Receipt (Stub for demo)
      let burn_receipt : BurnReceipt := {
        dt := QFixed.fromFloat 0.01,
        etaAvailable := QFixed.fromFloat 1000.0,
        spend := QFixed.zero,
        eModel := QFixed.fromFloat 0.5,
        eAct := QFixed.zero,
        eSensor := QFixed.zero,
        m_VDE := QFixed.fromFloat 5.0,
        m_tear := QFixed.fromFloat 2.0
      }

      -- 4. Execute FUS-1 Verifier
      match verifyIgnition hw_spec plasma_state burn_receipt with
      | VerifierResult.accept =>
        IO.println "VERIFIER_RESULT: ACCEPT"
        IO.println "Deterministic proof of affordability confirmed."
      | VerifierResult.reject_invalid_envelope msg =>
        IO.println s!"VERIFIER_RESULT: {msg}"
      | VerifierResult.reject_unauthorized_transition msg =>
        IO.println s!"VERIFIER_RESULT: {msg}"
      | VerifierResult.reject_unaffordable_burn msg =>
        IO.println s!"VERIFIER_RESULT: {msg}"
      | VerifierResult.reject_overflow msg =>
        IO.println s!"VERIFIER_RESULT: {msg}"
    else
      IO.println s!"Error: {state_json_path} not found."
  else
    IO.println s!"Error: {hw_json_path} not found."
