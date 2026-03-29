# Certificate Contract

## Purpose

This document defines the canonical hardware certificate schema and validation semantics for the Coh-Fusion verifier. It establishes the hardware certificate as a first-class authority gate in the typed tower.

---

## Canonical Certificate Schema

### HardwareCertificate Structure

```lean
structure HardwareCertificate where
  certificate_id     : String
  hardware_id        : String

  -- Performance & Limits
  latency            : QFixed  -- tau_sensor
  observation_error : QFixed
  slew_limit         : QFixed  -- I_dot_max
  saturation_limit  : QFixed  -- I_max

  -- Integrity & Governance
  operating_regime_hash : String  -- canon_profile_hash
  calibration_epoch   : String  -- timestamp of last calibration
  expiry              : String   -- not_after

  -- Crypto Root
  root_of_trust      : String
  signature          : String
```

**Location**: [`src/CohFusion/Product/HardwareCertificate.lean`](../src/CohFusion/Product/HardwareCertificate.lean)

### Fields Explained

| Field | Type | Purpose |
|-------|------|---------|
| `certificate_id` | `String` | Unique certificate identifier (pattern: `cert_[a-zA-Z0-9]{8}`) |
| `hardware_id` | `String` | Hardware component identifier |
| `latency` | `QFixed` | Sensor latency τ_sensor |
| `observation_error` | `QFixed` | Sensor uncertainty budget |
| `slew_limit` | `QFixed` | Maximum actuator rate of change I_dot_max |
| `saturation_limit` | `QFixed` | Maximum actuator saturation I_max |
| `operating_regime_hash` | `String` | Canon profile hash this certificate is valid for |
| `calibration_epoch` | `String` | ISO 8601 timestamp of last calibration |
| `expiry` | `String` | ISO 8601 date after which cert is invalid |
| `root_of_trust` | `String` | Hardware root of trust identifier |
| `signature` | `String` | Cryptographic signature (SHA-256, 64 hex chars) |

---

## Validation Semantics

### Certificate Validation Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Check       │───►│ Check       │───►│ Check       │───►│ Check       │
│ Expiry      │    │ Signature   │    │ Root of     │    │ Regime      │
│             │    │ Format      │    │ Trust       │    │ Matching   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Validation Functions

| Check | Function | Failure Class |
|-------|----------|---------------|
| Expiry | `isExpired cert today` | `CERT_EXPIRED` |
| Signature Shape | `hasRequiredSignatureShape cert` | `MISSING_SIGNATURE` |
| Signature Format | `hasValidSignatureFormat cert` | `INVALID_SIGNATURE_FORMAT` |
| Root of Trust | `hasRootOfTrust cert` | `MISSING_ROOT_OF_TRUST` |
| Regime Match | `matchesRegime cert expectedRegimeHash` | `REGIME_MISMATCH` |

### Failure Classes

| Code | Meaning | Action |
|------|---------|--------|
| `CERT_EXPIRED` | Certificate past expiry date | Reject with hard gate |
| `MISSING_SIGNATURE` | Empty signature field | Reject with hard gate |
| `INVALID_SIGNATURE_FORMAT` | Malformed signature | Reject with hard gate |
| `MISSING_ROOT_OF_TRUST` | Empty root_of_trust | Reject with hard gate |
| `REGIME_MISMATCH` | Hash doesn't match expected | Reject with hard gate |

### Validation Function Definitions

```lean
def isExpired (cert : HardwareCertificate) (today : String) : Bool :=
  today > cert.expiry

def hasRequiredSignatureShape (cert : HardwareCertificate) : Bool :=
  cert.signature.length > 0

def hasValidSignatureFormat (cert : HardwareCertificate) : Bool :=
  let sig := cert.signature
  sig.length >= 64  -- SHA-256 produces 64 hex chars
  ∧ (sig.toList.all (fun c => c.isDigit ∨ ("abcdef".contains c) ∨ ("ABCDEF".contains c)))

def hasRootOfTrust (cert : HardwareCertificate) : Bool :=
  cert.root_of_trust.length > 0

def matchesRegime (cert : HardwareCertificate) (expectedRegimeHash : String) : Bool :=
  cert.operating_regime_hash = expectedRegimeHash
```

---

## Regime Matching

### Operating Regime Definition

An operating regime is identified by a canonical profile hash that encodes:

- **Control Algebra Version**: R0-R4 morphism version
- **Numeric Profile**: QFixed configuration reference
- **Maximum Control Magnitude**: Normalized actuator limits
- **Maximum Perturbation Bound**: Epsilon for perturbation analysis
- **Dissipation Spectral Bound**: Maximum spectral radius for dissipation operators

### Canon Profile Reference

**Location**: [`src/profile/canon_profile.json`](../src/profile/canon_profile.json)

### Regime Binding

The certificate's `operating_regime_hash` must match the active canonical profile. This ensures:

1. **Version Locking**: Control algebra versions are synchronized
2. **Parameter Consistency**: Risk parameters match those the certificate covers
3. **Audit Trail**: Certificates can be traced to specific configuration states

---

## Integration with Kernel

### Certificate in Commercial Wedge

The `CommercialWedge` structure incorporates certificates:

```lean
structure CommercialWedge where
  mode          : DeploymentMode
  certificate  : HardwareCertificate  -- First-class authority gate
  risk_params   : ParamsFus QFixed
  threshold     : QFixed
  defect_limit  : QFixed
  ...
  regime_id     : String
```

### Certificate-Gated Evaluation

```
ObservableChannels → MicroReceipt → Kernel Verifier → Certificate Validation → Decision
                                        ↑                              │
                                        └──────────────────────────────┘
                                              Gates kernel output
```

The certificate validation gates the kernel's output, ensuring that:

1. Only certified hardware can produce acceptable outcomes
2. Certificates bind to specific regime configurations
3. Expired or invalid certificates trigger automatic rejection

### Certificate-Aware Kernel Interface

The kernel does NOT directly validate certificates. Instead:

1. **Layer Separation**: Commercial wedge performs certificate validation
2. **Precondition**: Certificate must be valid before calling kernel
3. **Postcondition**: Receipt includes certificate ID for audit

---

## Binding into Receipt

### Receipt-Certificate Link

The canonical `MicroReceipt` does NOT directly embed certificates. Instead:

| Receipt Field | Certificate Binding |
|---------------|---------------------|
| `statePrev` | Certificate validates sensor state at time t |
| `stateNext` | Certificate validates actuator state at time t+1 |
| `spendAuth` | Certificate bounds maximum spend |
| `defectDeclared` | Certificate bounds observation error |

### Burn Receipt Alternative

For burn-facing contracts, `BurnReceipt` includes certificate ID:

```lean
structure BurnReceipt where
  dt            : QFixed
  etaAvailable  : QFixed
  spend         : QFixed
  eModel        : QFixed
  eAct          : QFixed
  eSensor       : QFixed
  margins       : ObservableMargins
  certificateId : String  -- Links to HardwareCertificate
```

---

## Deployment Mode Integration

### Certificate Validity by Mode

| Mode | Certificate Required | Validation Strictness |
|------|--------------------|----------------------|
| `replay` | Yes | Full validation (all checks) |
| `shadow` | Yes | Full validation, warn on failure |
| `advisory` | Yes | Full validation, warn on failure |
| `hard_gate` | **Yes** | Full validation, reject on failure |

**All modes require valid certificates.** Certificate is a first-class gate, not optional context.

---

## Test Vectors

### Validation Test Cases

| Case | Input | Expected Output |
|------|-------|-----------------|
| Valid cert | All fields valid, current date < expiry | `Except.ok` |
| Expired | today > expiry | `Except.error "CERT_EXPIRED"` |
| Missing signature | signature = "" | `Except.error "MISSING_SIGNATURE"` |
| Invalid format | signature short | `Except.error "INVALID_SIGNATURE_FORMAT"` |
| No root of trust | root_of_trust = "" | `Except.error "MISSING_ROOT_OF_TRUST"` |
| Regime mismatch | hash ≠ expected | `Except.error "REGIME_MISMATCH"` |

---

## Status

| Component | Status | Notes |
|------------|--------|-------|
| HardwareCertificate structure | ✅ Canonical | In Product/HardwareCertificate.lean |
| Validation functions | ✅ Canonical | isExpired, hasValidSignatureFormat, etc. |
| validateCertificate | ✅ Canonical | Full pipeline in Product/HardwareCertificate.lean |
| matchesRegime | ❌ Missing | Defined in contract, needs implementation |
| Certificate in CommercialWedge | ✅ Canonical | Embedded as first-class field |
| BurnReceipt binding | ✅ Canonical | certificateId field |
| Test vectors | ❌ Pending | Documented, needs test data |

---

*For certificate flow, see [`docs/certificate_flow.md`](docs/certificate_flow.md).*