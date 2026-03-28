# Appendix D: Canonical Receipt Encoding

## Overview

This document specifies the canonical encoding for receipts in the Coh-Fusion system. All receipts must follow this encoding for interoperability between the Lean formalization and the runtime verifier.

## Receipt Types

### 1. Control Receipt

Issued when a control action is executed and recorded in the ledger.

**Structure**:
```json
{
  "receipt_type": "control",
  "receipt_id": "ctrl_XXXX",
  "control_morphism": {
    "source": "R₄ object data",
    "target": "R₄ object data",
    "morphism_data": "encoded as base64"
  },
  "execution_timestamp": "ISO-8601",
  "hardware_ref": "hw_YYYY",
  "digest": "sha256 hash"
}
```

### 2. Burn Receipt

Issued when resources are consumed during control execution.

**Structure**:
```json
{
  "receipt_type": "burn",
  "receipt_id": "burn_XXXX",
  "control_receipt_ref": "ctrl_YYYY",
  "resources": {
    "fuel_consumed_mj": 123.45,
    "power_peak_mw": 5.67,
    "duration_ms": 890,
    "power_integration_mj": 456.78
  },
  "integrity_hash": "sha256"
}
```

### 3. Certificate Receipt

Issued when hardware certification is verified.

**Structure**:
```json
{
  "receipt_type": "certificate",
  "receipt_id": "cert_XXXX",
  "hardware_id": "hw_YYYY",
  "certificate_data": {
    "signature": "base64",
    "timestamp": "ISO-8601",
    "root_of_trust": "rot_ZZZZ"
  },
  "verification_result": "valid | invalid | expired"
}
```

## Encoding Rules

### JSON Formatting

- Use 2-space indentation
- Use UTF-8 encoding
- Use lowercase for field names (snake_case)
- Include trailing newline

### Digest Computation

All receipts include a SHA-256 digest computed over:
1. Receipt type
2. Receipt ID
3. All payload fields (sorted alphabetically)
4. Canonical JSON serialization (no whitespace variance)

### Binary Encoding

For Lean serialization:
```lean
def encodeReceipt (r : Receipt) : ByteArray :=
  Json.encode r |> String.toUTF8
```

## Schema Files

- Control receipt: Use runtime validation
- Burn receipt: See [`src/schema/burn_receipt_schema.json`](src/schema/burn_receipt_schema.json)
- Certificate receipt: See [`src/schema/hardware_certificate_schema.json`](src/schema/hardware_certificate_schema.json)

## Canonical Form

A receipt is canonical if:
1. It validates against its JSON schema
2. Its digest matches the computed SHA-256
3. All timestamps are in UTC
4. All IDs follow the naming convention (`type_XXXX`)

## Validation

The runtime verifier must check:
1. Schema validity (JSON parse + field presence)
2. Digest correctness (recompute and compare)
3. Timestamp freshness (not expired)
4. ID format correctness

## References

- [`src/schema/receipt_schema.json`](src/schema/receipt_schema.json) — Base receipt schema
- [`src/schema/burn_receipt_schema.json`](src/schema/burn_receipt_schema.json) — Burn receipt schema
- [`src/schema/hardware_certificate_schema.json`](src/schema/hardware_certificate_schema.json) — Certificate schema
- [`docs/07a_hardware_certification.md`](docs/07a_hardware_certification.md)