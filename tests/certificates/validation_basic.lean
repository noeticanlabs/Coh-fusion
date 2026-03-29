import CohFusion.Product.HardwareCertificate
import CohFusion.Numeric.QFixed

namespace Tests.Certificates

/--
  Certificate validation tests.

  The validation pipeline:
  1. isExpired → CERT_EXPIRED
  2. hasRequiredSignatureShape → MISSING_SIGNATURE
  3. hasValidSignatureFormat → INVALID_SIGNATURE_FORMAT
  4. hasRootOfTrust → MISSING_ROOT_OF_TRUST
  5. matchesRegime → REGIME_MISMATCH
  6. Accept
--/

open CohFusion.Product
open CohFusion.Numeric

/-- Test 6.1: Valid certificate -/
#eval do
  let cert : HardwareCertificate :=
    { certificate_id := "cert_a1b2c3d4",
      hardware_id := "hw_sparc001",
      latency := ⟨18446744073709551616⟩,
      observation_error := ⟨1844674407370955⟩,
      slew_limit := ⟨18446744073709551616000⟩,
      saturation_limit := ⟨9223372036854775800000⟩,
      operating_regime_hash := "a1b2c3d4e5f6",
      calibration_epoch := "2026-01-15",
      expiry := "2027-12-31",
      root_of_trust := "sparc-root-001",
      signature := "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6" }

  let today := "2026-06-01"
  let expectedRegime := "a1b2c3d4e5f6"

  let result := validateCertificate today expectedRegime cert
  match result with
  | Except.ok _ => IO.println "Valid cert: PASS"
  | Except.error e => IO.println s!"Valid cert: FAIL - {e}"
  pure ()

/-- Test 6.2: Expired certificate -/
#eval do
  let cert : HardwareCertificate :=
    { certificate_id := "cert_expired01",
      hardware_id := "hw_sparc001",
      latency := ⟨18446744073709551616⟩,
      observation_error := ⟨1844674407370955⟩,
      slew_limit := ⟨18446744073709551616000⟩,
      saturation_limit := ⟨9223372036854775800000⟩,
      operating_regime_hash := "a1b2c3d4e5f6",
      calibration_epoch := "2026-01-15",
      expiry := "2025-12-31",
      root_of_trust := "sparc-root-001",
      signature := "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6" }

  let today := "2026-06-01"
  let expectedRegime := "a1b2c3d4e5f6"

  let result := validateCertificate today expectedRegime cert
  match result with
  | Except.ok _ => IO.println "Expired cert: FAIL - should reject"
  | Except.error e => IO.println s!"Expired cert: PASS - {e}"
  pure ()

/-- Test 6.3: Missing signature -/
#eval do
  let cert : HardwareCertificate :=
    { certificate_id := "cert_nosig001",
      hardware_id := "hw_sparc002",
      latency := ⟨18446744073709551616⟩,
      observation_error := ⟨1844674407370955⟩,
      slew_limit := ⟨18446744073709551616000⟩,
      saturation_limit := ⟨9223372036854775800000⟩,
      operating_regime_hash := "a1b2c3d4e5f6",
      calibration_epoch := "2026-01-15",
      expiry := "2027-12-31",
      root_of_trust := "sparc-root-001",
      signature := "" }

  let today := "2026-06-01"
  let expectedRegime := "a1b2c3d4e5f6"

  let result := validateCertificate today expectedRegime cert
  match result with
  | Except.ok _ => IO.println "Missing sig: FAIL - should reject"
  | Except.error e => IO.println s!"Missing sig: PASS - {e}"
  pure ()

/-- Test 6.4: Invalid signature format -/
#eval do
  let cert : HardwareCertificate :=
    { certificate_id := "cert_invsig01",
      hardware_id := "hw_sparc003",
      latency := ⟨18446744073709551616⟩,
      observation_error := ⟨1844674407370955⟩,
      slew_limit := ⟨18446744073709551616000⟩,
      saturation_limit := ⟨9223372036854775800000⟩,
      operating_regime_hash := "a1b2c3d4e5f6",
      calibration_epoch := "2026-01-15",
      expiry := "2027-12-31",
      root_of_trust := "sparc-root-001",
      signature := "xyz" }

  let today := "2026-06-01"
  let expectedRegime := "a1b2c3d4e5f6"

  let result := validateCertificate today expectedRegime cert
  match result with
  | Except.ok _ => IO.println "Invalid sig: FAIL - should reject"
  | Except.error e => IO.println s!"Invalid sig: PASS - {e}"
  pure ()

/-- Test 6.5: Missing root of trust -/
#eval do
  let cert : HardwareCertificate :=
    { certificate_id := "cert_noroot01",
      hardware_id := "hw_sparc004",
      latency := ⟨18446744073709551616⟩,
      observation_error := ⟨1844674407370955⟩,
      slew_limit := ⟨18446744073709551616000⟩,
      saturation_limit := ⟨9223372036854775800000⟩,
      operating_regime_hash := "a1b2c3d4e5f6",
      calibration_epoch := "2026-01-15",
      expiry := "2027-12-31",
      root_of_trust := "",
      signature := "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6" }

  let today := "2026-06-01"
  let expectedRegime := "a1b2c3d4e5f6"

  let result := validateCertificate today expectedRegime cert
  match result with
  | Except.ok _ => IO.println "Missing root: FAIL - should reject"
  | Except.error e => IO.println s!"Missing root: PASS - {e}"
  pure ()

/-- Test 6.6: Regime mismatch -/
#eval do
  let cert : HardwareCertificate :=
    { certificate_id := "cert_regmismatch",
      hardware_id := "hw_sparc005",
      latency := ⟨18446744073709551616⟩,
      observation_error := ⟨1844674407370955⟩,
      slew_limit := ⟨18446744073709551616000⟩,
      saturation_limit := ⟨9223372036854775800000⟩,
      operating_regime_hash := "legacy_hash_v1",
      calibration_epoch := "2026-01-15",
      expiry := "2027-12-31",
      root_of_trust := "sparc-root-001",
      signature := "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6" }

  let today := "2026-06-01"
  let expectedRegime := "a1b2c3d4e5f6"

  let result := validateCertificate today expectedRegime cert
  match result with
  | Except.ok _ => IO.println "Regime mismatch: FAIL - should reject"
  | Except.error e => IO.println s!"Regime mismatch: PASS - {e}"
  pure ()

end Tests.Certificates
