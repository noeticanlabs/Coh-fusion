# Hardware Certification Layer

## Overview

The hardware certification layer establishes the contract between the formal control algebra and physical hardware components in the fusion reactor control system.

## Certification Schema

### Hardware Certificate

A hardware certificate attests that a given control action has been executed on verified hardware:

```json
{
  "certificate_id": "cert_XXXX",
  "hardware_id": "hw_YYYY",
  "control_action": "R₄ morphism data",
  "timestamp": "ISO-8601",
  "signature": "hardware_root_of_trust_sig"
}
```

See [`src/schema/hardware_certificate_schema.json`](src/schema/hardware_certificate_schema.json) for full JSON schema.

### Burn Receipt

A burn receipt records the consumption of resources (fuel, power, time) during control execution:

```json
{
  "receipt_id": "burn_XXXX",
  "certificate_ref": "cert_YYYY",
  "fuel_consumed_MJ": 123.45,
  "power_peak_MW": 5.67,
  "duration_ms": 890,
  "integrity_hash": "sha256..."
}
```

See [`src/schema/burn_receipt_schema.json`](src/schema/burn_receipt_schema.json) for full JSON schema.

## Certification Flow

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────┐
│ Control     │───►│ Hardware     │───►│ Burn Receipt   │
│ Algebra     │    │ Certificate  │    │ Generation     │
└─────────────┘    └──────────────┘    └─────────────────┘
     R₄                  H/W                   Validation
```

## Gate Specification

The hardware gate contract defines:
- **Preconditions**: What must be true before control execution
- **Postconditions**: What must hold after execution
- **Invariant**: What remains true throughout

## Status

| Component | Status |
|-----------|--------|
| Certificate schema | ✅ Defined |
| Burn receipt schema | ✅ Defined |
| Gate contract | ✅ Specified |
| Validation logic | Stubbed |

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md)
- [`src/schema/hardware_certificate_schema.json`](src/schema/hardware_certificate_schema.json)
- [`src/schema/burn_receipt_schema.json`](src/schema/burn_receipt_schema.json)