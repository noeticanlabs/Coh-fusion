# Numeric Flow

## Operational Overview

This document shows how numeric values flow through the Coh-Fusion system.

---

## Numeric Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    EXTERNAL VALUES                                 │
│  • JSON fixtures (threshold, limits)                              │
│  • Hardware certificates                                          │
│  • User input / receipts                                           │
│  • Test vectors                                                   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PARSE LAYER                                     │
│                                                                      │
│  String → QFixed via fromDecimalString                              │
│  Error cases: Empty string, invalid format, multiple decimals      │
│                                                                      │
│  If parse fails: REJECT                                             │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BOUNDARY LAYER                                   │
│                                                                      │
│  Ensure all kernel inputs are QFixed                                │
│  No Float values allowed                                            │
│  No mixed numeric types in kernel                                    │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    KERNEL LAYER                                      │
│                                                                      │
│  All comparisons use QFixed:                                        │
│  - a < b  (a.raw < b.raw)                                           │
│  - a ≤ b  (a.raw ≤ b.raw)                                            │
│  - a > b  (b < a)                                                   │
│  - a ≥ b  (b ≤ a)                                                   │
│                                                                      │
│  Decision:                                                          │
│  - threshold exceeded: a > b → REJECT                              │
│  - defect exceeded: a > b → REJECT                                 │
│  - oplax violation: compute → REJECT                                 │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    OUTPUT LAYER                                     │
│                                                                      │
│  If ACCEPT: receipt contains QFixed values (serialized as strings)  │
│  If REJECT: error code + reason                                      │
│                                                                      │
│  Replay: parse receipt values → same decision guaranteed            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Types

### Kernel Numeric Types

| Type | Use | Canonical? |
|------|-----|------------|
| `QFixed` | Risk, thresholds, defects, spend | ✅ Yes |
| `State6 QFixed` | Observable state | ✅ Yes |
| `ParamsFus QFixed` | Geometry parameters | ✅ Yes |

### Non-Canonical Types

| Type | Use | Notes |
|------|-----|-------|
| `Float` | Display/logging only | Never in kernel |
| `Int` | Adapter layer | Must convert to QFixed |
| `Rat` | Theorem layer | Not in kernel |

---

## Comparison Rules

### Open Set Semantics (Canonical)

| Condition | Kernel Action |
|-----------|----------------|
| `risk > threshold` | REJECT |
| `risk ≤ threshold` | ACCEPT |
| `defect > limit` | REJECT |
| `defect ≤ limit` | ACCEPT |

### Equality Behavior

- **Equality at boundary**: ACCEPTED (open set)
- **Zero comparison**: Exact via `raw = 0`

---

## Failure Modes

| Failure | Kernel Action |
|---------|---------------|
| Parse error | REJECT (parse failure code) |
| Division by zero | REJECT (numeric error code) |
| Invalid input | REJECT (schema invalid) |

---

## Replay Flow

```
Original decision:
  Input → Parse → QFixed → Kernel → Decision

Replay:
  Receipt → Parse fields → QFixed → Kernel → SAME Decision
```

Because:
1. Parsing is deterministic (exact integer arithmetic)
2. Kernel comparisons are exact
3. No non-deterministic operations

---

*Last updated: 2026-03-29*
