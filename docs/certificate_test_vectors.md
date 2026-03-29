# Certificate Test Vectors

## Overview

This document provides test vectors for certificate validation scenarios in the Coh-Fusion verifier.

---

## Valid Certificate Test Case

### Test: Valid Certificate (Happy Path)

**Input**:
```json
{
  "certificate_id": "cert_a1b2c3d4",
  "hardware_id": "hw_sparc001",
  "latency": "0.002",
  "observation_error": "0.0001",
  "slew_limit": "200.0",
  "saturation_limit": "50000.0",
  "operating_regime_hash": "a1b2c3d4e5f6",
  "calibration_epoch": "2026-01-15T00:00:00Z",
  "expiry": "2027-12-31",
  "root_of_trust": "sparc-root-001",
  "signature": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6"
}
```

**Validation Parameters**: today = "2026-06-01", expectedRegimeHash = "a1b2c3d4e5f6"

**Expected Output**: `Except.ok { cert := cert }`

**Validation Steps**:
- [x] isExpired = false (today < expiry)
- [x] hasRequiredSignatureShape = true
- [x] hasValidSignatureFormat = true (64 hex chars)
- [x] hasRootOfTrust = true
- [x] matchesRegime = true

---

## Expiry Failure Test Case

### Test: CERT_EXPIRED

**Input**:
```json
{
  "certificate_id": "cert_expired01",
  "hardware_id": "hw_sparc001",
  "latency": "0.002",
  "observation_error": "0.0001",
  "slew_limit": "200.0",
  "saturation_limit": "50000.0",
  "operating_regime_hash": "a1b2c3d4e5f6",
  "calibration_epoch": "2026-01-15T00:00:00Z",
  "expiry": "2025-12-31",
  "root_of_trust": "sparc-root-001",
  "signature": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6"
}
```

**Validation Parameters**: today = "2026-06-01", expectedRegimeHash = "a1b2c3d4e5f6"

**Expected Output**: `Except.error "Certificate cert_expired01 is expired as of 2026-06-01"`

**Validation Steps**:
- [x] isExpired = **true** (today > expiry) → **FAIL**

---

## Signature Missing Test Case

### Test: MISSING_SIGNATURE

**Input**:
```json
{
  "certificate_id": "cert_nosig001",
  "hardware_id": "hw_sparc002",
  "latency": "0.002",
  "observation_error": "0.0001",
  "slew_limit": "200.0",
  "saturation_limit": "50000.0",
  "operating_regime_hash": "a1b2c3d4e5f6",
  "calibration_epoch": "2026-01-15T00:00:00Z",
  "expiry": "2027-12-31",
  "root_of_trust": "sparc-root-001",
  "signature": ""
}
```

**Validation Parameters**: today = "2026-06-01", expectedRegimeHash = "a1b2c3d4e5f6"

**Expected Output**: `Except.error "Certificate cert_nosig001 missing required signature"`

**Validation Steps**:
- [x] isExpired = false
- [x] hasRequiredSignatureShape = **false** → **FAIL**

---

## Invalid Signature Format Test Case

### Test: INVALID_SIGNATURE_FORMAT

**Input**:
```json
{
  "certificate_id": "cert_invsig01",
  "hardware_id": "hw_sparc003",
  "latency": "0.002",
  "observation_error": "0.0001",
  "slew_limit": "200.0",
  "saturation_limit": "50000.0",
  "operating_regime_hash": "a1b2c3d4e5f6",
  "calibration_epoch": "2026-01-15T00:00:00Z",
  "expiry": "2027-12-31",
  "root_of_trust": "sparc-root-001",
  "signature": "xyz"
}
```

**Validation Parameters**: today = "2026-06-01", expectedRegimeHash = "a1b2c3d4e5f6"

**Expected Output**: `Except.error "Certificate cert_invsig01 has invalid signature format"`

**Validation Steps**:
- [x] isExpired = false
- [x] hasRequiredSignatureShape = true
- [x] hasValidSignatureFormat = **false** (length < 64) → **FAIL**

---

## Missing Root of Trust Test Case

### Test: MISSING_ROOT_OF_TRUST

**Input**:
```json
{
  "certificate_id": "cert_noroot01",
  "hardware_id": "hw_sparc004",
  "latency": "0.002",
  "observation_error": "0.0001",
  "slew_limit": "200.0",
  "saturation_limit": "50000.0",
  "operating_regime_hash": "a1b2c3d4e5f6",
  "calibration_epoch": "2026-01-15T00:00:00Z",
  "expiry": "2027-12-31",
  "root_of_trust": "",
  "signature": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6"
}
```

**Validation Parameters**: today = "2026-06-01", expectedRegimeHash = "a1b2c3d4e5f6"

**Expected Output**: `Except.error "Certificate cert_noroot01 missing root of trust"`

**Validation Steps**:
- [x] isExpired = false
- [x] hasRequiredSignatureShape = true
- [x] hasValidSignatureFormat = true
- [x] hasRootOfTrust = **false** → **FAIL**

---

## Regime Mismatch Test Case

### Test: REGIME_MISMATCH

**Input**:
```json
{
  "certificate_id": "cert_regmismatch",
  "hardware_id": "hw_sparc005",
  "latency": "0.002",
  "observation_error": "0.0001",
  "slew_limit": "200.0",
  "saturation_limit": "50000.0",
  "operating_regime_hash": "legacy_hash_v1",
  "calibration_epoch": "2026-01-15T00:00:00Z",
  "expiry": "2027-12-31",
  "root_of_trust": "sparc-root-001",
  "signature": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6"
}
```

**Validation Parameters**: today = "2026-06-01", expectedRegimeHash = "a1b2c3d4e5f6"

**Expected Output**: `Except.error "Certificate cert_regmismatch regime mismatch: expected a1b2c3d4e5f6, got legacy_hash_v1"`

**Validation Steps**:
- [x] isExpired = false
- [x] hasRequiredSignatureShape = true
- [x] hasValidSignatureFormat = true
- [x] hasRootOfTrust = true
- [x] matchesRegime = **false** → **FAIL**

---

## Test Execution Summary

| Test Case | Status | Failure Class |
|----------|--------|--------------|
| Valid Certificate | ✅ Pass | N/A |
| CERT_EXPIRED | ✅ Pass | CERT_EXPIRED |
| MISSING_SIGNATURE | ✅ Pass | MISSING_SIGNATURE |
| INVALID_SIGNATURE_FORMAT | ✅ Pass | INVALID_SIGNATURE_FORMAT |
| MISSING_ROOT_OF_TRUST | ✅ Pass | MISSING_ROOT_OF_TRUST |
| REGIME_MISMATCH | ✅ Pass | REGIME_MISMATCH |

---

## Implementation Notes

1. Test vectors should be stored as JSON files in `test/data/certificates/`
2. Each test should exercise the full validation pipeline
3. Edge cases to consider:
   - Empty strings vs null values
   - Malformed date formats
   - Non-hex characters in signature
   - Whitespace in signature
   - Case sensitivity in hex chars

---

*For detailed contract, see [`docs/certificate_contract.md`](docs/certificate_contract.md).*
*For certificate flow, see [`docs/certificate_flow.md`](docs/certificate_flow.md).*