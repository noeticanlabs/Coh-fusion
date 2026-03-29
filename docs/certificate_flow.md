# Certificate Flow

## Overview

This document shows the hardware certificate pipeline: from issuance through validation to consumption in the verifier. The certificate is a first-class authority gate in the typed tower.

---

## Pipeline Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Hardware    │───►│ Certificate │───►│ Regime      │───►│ Certificate│───►│ Verifier    │
│ Provision   │    │ Issuance    │    │ Binding     │    │ Validation │    │ Consumption│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                                      │
                                                                                      ▼
                                                                         ┌─────────────┐
                                                                         │ Decision   │
                                                                         │ Output     │
                                                                         └─────────────┘
```

---

## Stage 1: Hardware Provision

### Input Requirements

| Field | Source | Description |
|-------|--------|-------------|
| `hardware_id` | Physical hardware | Unique identifier (pattern: `hw_[a-zA-Z0-9]{8}`) |
| `latency` | Sensor characterization | τ_sensor in QFixed |
| `observation_error` | Sensor calibration | Measurement uncertainty |
| `slew_limit` | Actuator characterization | I_dot_max |
| `saturation_limit` | Actuator limits | I_max |

### Hardware Characterization Process

1. **Sensor Calibration**: Characterize latency and observation error
2. **Actuator Profiling**: Determine slew and saturation limits
3. **ID Assignment**: Assign unique hardware_id
4. **Root of Trust Binding**: Associate with hardware root of trust

---

## Stage 2: Certificate Issuance

### Issuance Function

```lean
/-- Issue a new hardware certificate. -/
def issueCertificate
    (hardware_id : String)
    (latency observation_error slew_limit saturation_limit : QFixed)
    (root_of_trust : String)
    (calibration_epoch expiry : String)
    (regime_id : String)
    (canon_profile_hash : String)
    (signature : String) : HardwareCertificate :=
  { certificate_id       := "cert_" ++ hash8 hardware_id
  , hardware_id         := hardware_id
  , latency             := latency
  , observation_error  := observation_error
  , slew_limit          := slew_limit
  , saturation_limit   := saturation_limit
  , operating_regime_hash := canon_profile_hash
  , calibration_epoch  := calibration_epoch
  , expiry              := expiry
  , root_of_trust       := root_of_trust
  , signature          := signature }
```

### Certificate Lifecycle

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Issued  │───►│ Active  │───►│ Valid   │───►│ Expired │───►│ Revoked │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
                │              │              │
                │    today ∈   │    today >  │
                │    [not_      │    expiry   │
                │     before,   │              │
                │     not_after]│              │
```

| State | Condition | Mode Impact |
|-------|-----------|--------------|
| Issued | Certificate created | N/A - not usable yet |
| Active | Within validity period | Full validation passes |
| Expired | today > expiry | Hard rejection |
| Revoked | Explicit revocation | Hard rejection |

---

## Stage 3: Regime Binding

### Canon Profile Reference

The certificate binds to a specific canon profile:

```json
{
  "control_algebra_version": "r0-r4-v3",
  "numeric_profile_ref": "Q-fixed-2^64",
  "hardware_root_of_trust": "sparc-root",
  "max_control_magnitude": 1.0,
  "max_perturbation_bound": 0.01,
  "dissipation_spectral_bound": 0.95
}
```

### Regime Binding Rules

1. **Hash Matching**: `operating_regime_hash = canon_profile_hash`
2. **Version Locking**: Control algebra versions synchronized
3. **Parameter Consistency**: Certificate limits must satisfy profile constraints

---

## Stage 4: Certificate Validation

### Validation Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          validateCertificate                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Input: cert, today, expectedRegimeHash                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Step 1: isExpired(cert, today)                                             │
│          ├─ true  → Except.error "CERT_EXPIRED"                              │
│          └─ false → Step 2                                                 │
│                                                                             │
│  Step 2: hasRequiredSignatureShape(cert)                                   │
│          ├─ false → Except.error "MISSING_SIGNATURE"                      │
│          └─ true  → Step 3                                                 │
│                                                                             │
│  Step 3: hasValidSignatureFormat(cert)                                       │
│          ├─ false → Except.error "INVALID_SIGNATURE_FORMAT"              │
│          └─ true  → Step 4                                                 │
│                                                                             │
│  Step 4: hasRootOfTrust(cert)                                               │
│          ├─ false → Except.error "MISSING_ROOT_OF_TRUST"                    │
│          └─ true  → Step 5                                                 │
│                                                                             │
│  Step 5: matchesRegime(cert, expectedRegimeHash)                           │
│          ├─ false → Except.error "REGIME_MISMATCH"                         │
│          └─ true  → Except.ok {cert := cert}                                 │
└─────────────────────────────────────────��───────────────────────────────────────┘
```

### Validation Function

```lean
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
```

---

## Stage 5: Verifier Consumption

### Commercial Wedge Integration

The certificate is consumed in the commercial wedge:

```lean
def evaluateTransition
    (wedge : CommercialWedge)
    (expectedState nextState : ObservableChannels)
    (spend defect : QFixed) : WedgeDecision :=
  -- First: Validate certificate (first-class gate)
  match validateCertificate
         today
         wedge.regime_id
         wedge.certificate with
  | Except.error e => WedgeDecision.reject RejectCode.cert_invalid e
  | Except.ok _ =>
    -- Second: Build and verify receipt
    let r := buildMicroReceipt wedge expectedState nextState spend defect
    let outcome := CohFusion.Runtime.verifyRV_QFixed ...

    -- Third: Map to wedge decision
    decide wedge outcome
```

### Full Consumption Flow

```
┌──────────────┐    ┌────────────┐    ┌────────────┐    ┌────────────┐
│ Observable  │───►│ Validate   │───►│ Build      │───►│ Verify    │
│ Channels    │    │ Certificate│    │ Receipt    │    │ kernel    │
└──────────────┘    └────────────┘    └────────────┘    └────────────┘
                                          │                    │
                                          ▼                    ▼
                                   ┌────────────┐    ┌────────────┐
                                   │ Map to     │◄───│ Decision  │
                                   │ Decision   │    │ Output    │
                                   └────────────┘    └────────────┘
```

---

## Deployment Mode Behavior

### Replay Mode

- Full certificate validation required
- Reject on any validation failure
- Trust anchor is historical certificate

### Shadow Mode

- Full certificate validation required
- Warn on validation failures
- No control intervention

### Advisory Mode

- Full certificate validation required  
- Warn on validation failures
- Operator alerts issued

### Hard Gate Mode

- **Full certificate validation required**
- Reject on any validation failure
- Blocks control action execution

---

## Failure Recovery

| Failure | Recovery Action |
|---------|---------------|
| CERT_EXPIRED | Re-issue certificate with new expiry |
| MISSING_SIGNATURE | Re-sign with root of trust |
| INVALID_SIGNATURE_FORMAT | Re-sign with correct format |
| MISSING_ROOT_OF_TRUST | Bind to valid root |
| REGIME_MISMATCH | Re-issue for current regime |

---

## Audit Trail

### Certificate in Receipt

Each receipt should carry the certificate reference:

```
Receipt.metadata.certificate_id → HardwareCertificate.certificate_id
```

This creates an audit chain:

1. Certificate → Hardware provisioning event
2. Receipt → Control action evidence
3. Decision → Verdict with certificate context

### Retention Policy

- Certificates retained for entire liability period
- Receipts retained for audit + 30 years
- Cross-reference via certificate_id

---

## Status

| Stage | Status | Implementation |
|-------|--------|---------------|
| Hardware provision | ✅ Defined | External process |
| Certificate issuance | ✅ Defined | HardwareCertificate.lean |
| Regime binding | ✅ Defined | canon_profile.json |
| Certificate validation | ✅ Canonical | validateCertificate |
| Verifier consumption | ✅ Canonical | CommercialWedge.lean |

---

*For detailed contract, see [`docs/certificate_contract.md`](docs/certificate_contract.md).*