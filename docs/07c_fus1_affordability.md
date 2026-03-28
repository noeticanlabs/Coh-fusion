# FUS-1: Affordability Doctrine

## Overview

FUS-1 is the affordability doctrine that governs resource allocation decisions in the Coh-Fusion control architecture. It establishes the principles for determining when a control action is "affordable" in terms of fuel, power, time, and risk.

## Core Principles

### Principle 1: Bounded Resource Consumption

Every control action must consume bounded resources:

```math
∀ c ∈ C: resource(c) ≤ R_max
```

Where R_max is the maximum allowable resource consumption for the current operational mode.

### Principle 2: Marginal Affordability

The marginal cost of an additional control action must not exceed the remaining budget:

```math
marginal_cost(c_next) ≤ remaining_budget
```

### Principle 3: Risk-Adjusted Returns

Affordability is computed with risk adjustment:

```math
affordable(c) ⟺ (expected_benefit(c) / risk_factor(c)) ≥ threshold
```

### Principle 4: Operational Mode Scaling

Resource limits scale with operational mode:

| Mode | Fuel Limit (MJ) | Power Limit (MW) | Duration Limit (ms) |
|------|-----------------|------------------|---------------------|
| Startup | 100 | 5 | 500 |
| Flat-top | 500 | 10 | 5000 |
| Rampdown | 50 | 2 | 200 |

## Implementation

The affordability check is implemented in the runtime verifier:
- See [`src/CohFusion/Numeric/Policy.lean`](src/CohFusion/Numeric/Policy.lean) for enforcement logic
- See [`src/profile/numeric_profile.md`](src/profile/numeric_profile.md) for numeric bounds

## Status

- **Doctrine specification**: Complete
- **Implementation**: Partial (policy module exists)
- **Mode scaling**: Specified in profile

## References

- [`docs/00_status_matrix.md`](00_status_matrix.md)
- [`src/profile/numeric_profile.md`](src/profile/numeric_profile.md)