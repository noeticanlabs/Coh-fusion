# Hardware Certification Layer

## Overview

The hardware certification layer establishes the contract between the formal control algebra and physical hardware components in the fusion reactor control system.

## Certification Schema

### Hardware Certificate

A hardware certificate attests that a given control action has been executed on verified hardware. It is now represented as a typed object in Lean:

- **Lean Definition**: [`src/CohFusion/Product/HardwareCertificate.lean`](../src/CohFusion/Product/HardwareCertificate.lean)
- **Schema**: [`src/schema/hardware_certificate_schema.json`](../src/schema/hardware_certificate_schema.json)

### Burn Receipt

A burn receipt records the consumption of resources and evaluated margins. It is generated through a staged pipeline in the FUS-1 verifier.

- **Lean Definition**: [`src/CohFusion/Control/BurnContract.lean`](../src/CohFusion/Control/BurnContract.lean)
- **Pipeline Implementation**: [`src/CohFusion/Control/BurnPolicyDemo.lean`](../src/CohFusion/Control/BurnPolicyDemo.lean)

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
| Certificate schema | ✅ Complete (Typed Lean Object) |
| Burn receipt schema | ✅ Complete (Staged Pipeline) |
| Gate contract | ✅ Complete (Commercial Wedge Hard-Gate) |
| Validation logic | ✅ Integrated (verifyIgnition_v3) |

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md)
- [`src/schema/hardware_certificate_schema.json`](src/schema/hardware_certificate_schema.json)
- [`src/schema/burn_receipt_schema.json`](src/schema/burn_receipt_schema.json)