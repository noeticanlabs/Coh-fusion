import Lean.Data.Json
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize

namespace CohFusion.Product

open CohFusion.Numeric

/--
  Typed Hardware Certificate for the Coh-Fusion commercial wedge.
  Maps to the `hardware_certificate_schema.json`.
-/
structure HardwareCertificate where
  certificate_id     : String
  hardware_id        : String

  -- Performance & Limits
  latency            : QFixed -- tau_sensor
  observation_error  : QFixed
  slew_limit         : QFixed -- I_dot_max
  saturation_limit   : QFixed -- I_max

  -- Integrity & Governance
  operating_regime_hash : String -- canon_profile_hash
  calibration_epoch     : String -- timestamp of last calibration
  expiry                : String -- not_after

  -- Crypto Root
  root_of_trust      : String
  signature          : String
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Validated certificate with preprocessing results. -/
structure ValidatedCertificate where
  cert : HardwareCertificate
  -- Derived fields could be added here (e.g., is_expired, days_until_expiry)

/-- Check if certificate is expired relative to today's date string (YYYY-MM-DD). -/
def isExpired (cert : HardwareCertificate) (today : String) : Bool :=
  today > cert.expiry

/-- Check if certificate has required signature shape (non-empty).
    NOTE: This is a basic structural check. Production should verify
    cryptographic signature validity against root_of_trust. -/
def hasRequiredSignatureShape (cert : HardwareCertificate) : Bool :=
  cert.signature.length > 0

/-- Check if certificate has a valid signature format.
    In production, this should perform cryptographic verification. -/
def hasValidSignatureFormat (cert : HardwareCertificate) : Bool :=
  -- Basic format check: signature should be hex-encoded and of proper length
  let sig := cert.signature
  sig.length >= 64 -- SHA-256 produces 64 hex chars
  /\
  (sig.toList.all (fun c => c.isDigit ∨ ("abcdef".contains c) ∨ ("ABCDEF".contains c)))

/-- Check if certificate root of trust is defined. -/
def hasRootOfTrust (cert : HardwareCertificate) : Bool :=
  cert.root_of_trust.length > 0

/-- Validate certificate and return either an error or validated certificate. -/
def validateCertificate
    (today : String)
    (expectedRegimeHash : String)
    (cert : HardwareCertificate) : Except String ValidatedCertificate :=
  if isExpired cert today then
    Except.error s!"Certificate {cert.certificate_id} is expired as of {today}"
  else if ¬hasRequiredSignatureShape cert then
    Except.error s!"Certificate {cert.certificate_id} missing required signature"
  else if ¬hasValidSignatureFormat cert then
    Except.error s!"Certificate {cert.certificate_id} has invalid signature format"
  else if ¬hasRootOfTrust cert then
    Except.error s!"Certificate {cert.certificate_id} missing root of trust"
  else if ¬matchesRegime cert expectedRegimeHash then
    Except.error s!"Certificate {cert.certificate_id} regime mismatch: expected {expectedRegimeHash}, got {cert.operating_regime_hash}"
  else
    Except.ok { cert := cert }

end CohFusion.Product
