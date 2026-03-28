# Observable Sufficiency Stress Tests

## Overview

Observable sufficiency stress tests verify that the hardware certification layer correctly detects and rejects invalid control actions under extreme conditions.

## Test Categories

### 1. Boundary Overflow Tests

Test that numeric overflow in QFixed representation is correctly detected:

- Maximum control magnitude exceeded
- Perturbation bounds violated
- Temporal bounds exceeded

### 2. Stability Violation Tests

Test that unstable control sequences are rejected:

- Composed controls that violate R₃ stability
- Dissipation operators with ρ(D) > 1
- Sequential composition accumulating instability

### 3. Geometric Transversality Tests

Test that non-transverse controls are rejected:

- Controls intersecting boundary manifold
- Jacobian singularities
- Coordinate transform failures

### 4. Certificate Integrity Tests

Test that malformed or forged certificates are rejected:

- Invalid signatures
- Expired timestamps
- Mismatched hardware IDs

## Test Vector Format

Each stress test is a JSON document containing:
- `test_id`: Unique identifier
- `category`: Test category
- `input`: Control action or certificate data
- `expected_outcome`: "accept" or "reject"
- `rationale`: Why this tests observable sufficiency

## Status

- **Test framework**: Specified
- **Test vectors**: Not started
- **Golden rejection cases**: Not started

## Implementation Notes

The runtime verifier must implement:
- Strict bounds checking on all numeric inputs
- Certificate signature verification against hardware root of trust
- Timeout/retry limits for hardware communication

## References

- [`docs/07a_hardware_certification.md`](07a_hardware_certification.md)
- [`docs/00_status_matrix.md`](00_status_matrix.md)