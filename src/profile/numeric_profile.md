# Numeric Profile

## Overview

This document defines the numeric bounds and constraints used throughout the Coh-Fusion system.

## QFixed Configuration

### Precision

- **Integer bits**: 32
- **Fractional bits**: 32
- **Total width**: 64 bits

### Range

- **Minimum**: -2^31
- **Maximum**: 2^31 - 1
- **Epsilon**: 2^-32

## Operational Bounds

### Control Magnitude

| Mode | Max Magnitude | Notes |
|------|---------------|-------|
| Startup | 0.5 | Conservative bound |
| Flat-top | 1.0 | Full range |
| Rampdown | 0.3 | Reduced for safety |

### Perturbation Bounds

| Layer | Max ε | Rationale |
|-------|-------|-----------|
| R₁ | 0.1 | Small perturbation regime |
| R₂ | 0.2 | Composition may amplify |
| R₃ | 0.15 | Stability preservation |
| R₄ | 0.25 | Full categorical closure |

### Dissipation Bounds

- **Spectral radius ρ(D)**: ≤ 0.99
- **Norm bound**: ≤ 1.0
- **Composition limit**: 10 sequential dissipations

## Resource Bounds (FUS-1)

### Fuel Consumption

| Mode | Max MJ | Warning Threshold |
|------|--------|------------------|
| Startup | 100 | 80 |
| Flat-top | 500 | 400 |
| Rampdown | 50 | 40 |

### Power Limits

| Mode | Peak MW | Average MW |
|------|---------|------------|
| Startup | 5 | 2 |
| Flat-top | 10 | 5 |
| Rampdown | 2 | 1 |

### Duration Limits

| Mode | Max ms | Hard Timeout |
|------|--------|--------------|
| Startup | 500 | 600 |
| Flat-top | 5000 | 5500 |
| Rampdown | 200 | 250 |

## Numeric Overflow Handling

All numeric operations must check for overflow:
- Addition: Check result ∈ [min, max]
- Multiplication: Check result ∈ [min, max]
- Division: Check divisor ≠ 0 and quotient bounded

## References

- [`src/CohFusion/Numeric/QFixed.lean`](src/CohFusion/Numeric/QFixed.lean) — Fixed-point implementation
- [`docs/07c_fus1_affordability.md`](docs/07c_fus1_affordability.md) — FUS-1 doctrine