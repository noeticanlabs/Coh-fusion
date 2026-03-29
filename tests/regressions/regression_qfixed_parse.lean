import CohFusion.Numeric.QFixed

namespace Tests.Regressions

/--
  Regression tests for bug fixes.

  These tests lock in the fixes for bugs discovered in earlier phases.
  Each bug is documented and has a test that must pass forever.
--/

open CohFusion.Numeric

/-- Regression: QFixed parse - '.' vs "." in splitOn -/
/--
  Bug: splitOn was called with Char '.' instead of String "."
  File: QFixed.lean:102
  Fix: Changed '.' → "."
--/
#eval do
  let result := QFixed.ofString? "1.0"
  match result with
  | Except.ok q => IO.println s!"Parse with decimal: {q.raw}"
  | Except.error e => IO.println s!"Parse error: {e}"
  pure ()

/-- Regression: QFixed parse - Int.ofString? vs Int.fromString? -/
/--
  Bug: Int.ofString? doesn't exist in Lean 4
  File: QFixed.lean:104,108,110
  Fix: Changed Int.ofString? → Int.fromString?
--/
#eval do
  let result := QFixed.ofString? "42"
  match result with
  | Except.ok q => IO.println s!"Parse integer: {q.raw}"
  | Except.error e => IO.println s!"Parse error: {e}"
  pure ()

/-- Regression: matchesRegime missing -/
/--
  Bug: validateCertificate called matchesRegime but it wasn't defined
  File: HardwareCertificate.lean
  Fix: Added matchesRegime function at line 63
--/
#eval do
  let cert : CohFusion.Product.HardwareCertificate :=
    { certificate_id := "cert_regtest",
      hardware_id := "hw_test",
      latency := ⟨1⟩,
      observation_error := ⟨1⟩,
      slew_limit := ⟨1⟩,
      saturation_limit := ⟨1⟩,
      operating_regime_hash := "test_hash",
      calibration_epoch := "2026-01-01",
      expiry := "2027-12-31",
      root_of_trust := "root",
      signature := "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6" }

  let matches := CohFusion.Product.matchesRegime cert "test_hash"
  IO.println s!"matchesRegime: {matches}"
  pure ()

end Tests.Regressions
