# Receipt Flow

## Operational Overview

This document shows how receipts are created, validated, and replayed in the Coh-Fusion system.

---

## Receipt Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DECISION LAYER                                   │
│                                                                      │
│  Kernel: verifyRV_QFixed                                            │
│  Inputs: MicroReceipt, ParamsFus, threshold, defectLimit, gamma    │
│  Output: Decision (accept or reject)                               │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    RECEIPT ISSUANCE                                 │
│                                                                      │
│  On ACCEPT:                                                          │
│    • Capture statePrev (State6)                                     │
│    • Capture stateNext (State6)                                     │
│    • Capture spendAuth (QFixed)                                      │
│    • Capture defectDeclared (QFixed)                                 │
│    • Serialize to receipt schema                                     │
│                                                                      │
│  On REJECT:                                                          │
│    • No receipt issued (reject code provides evidence)              │
│    • Or issue "rejection receipt" with reason                        │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    STORAGE / TRANSMISSION                            │
│                                                                      │
│  Receipts can be:                                                    │
│    • Stored in ledger                                               │
│    • Transmitted as evidence                                        │
│    • Archived for audit                                              │
│                                                                      │
│  Serialization: JSON (with QFixed as decimal strings)               │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    REPLAY / VALIDATION                              │
│                                                                      │
│  1. Parse receipt (MicroReceipt)                                    │
│  2. Verify statePrev matches expected state                          │
│  3. Reconstruct kernel inputs                                        │
│  4. Recompute decision via verifyRV_QFixed                           │
│  5. Compare: recomputed vs recorded                                  │
│                                                                      │
│  If match: ACCEPT (evidence verified)                                │
│  If mismatch: REJECT (tampering detected)                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Receipt Types

### Canonical

| Type | Use | Location |
|------|-----|----------|
| `MicroReceipt` | Single-step transition | `Core/Receipt.lean` |

### Non-Canonical (Draft/Adapter)

| Type | Use | Notes |
|------|-----|-------|
| `BurnReceipt` | Demo pipeline | Adapter |
| `HashBoundedReceipt` | With digest | Draft |
| `SlabReceipt` | Multi-step | Draft |

---

## State Linkage

### Linkage Model

```
receipt.statePrev ──────► Expected previous state
         │                            │
         │     Kernel checks:        │
         │     statePrev = expected   │
         ▼                            ▼
    ACCEPT (match)              REJECT (mismatch)
```

### Verification

- Receipt contains full `State6` (6 observables)
- No hashing required — state is directly embedded
- Replay verifies equality

---

## Trace Linkage

### Current State

- `traceLinked` function checks sequential linkage
- Each receipt's `stateNext` must equal next receipt's `statePrev`

### Trace Flow

```
Receipt 1: statePrev=A, stateNext=B
Receipt 2: statePrev=B, stateNext=C
Receipt 3: statePrev=C, stateNext=D

traceLinked([R1, R2, R3]) = true
```

### Failure

If `traceLinked = false`, kernel returns `stateHashLinkFail`.

---

## Certificate Context

### Current Model

Certificates are NOT embedded in receipts.
They are validated externally before kernel evaluation.

### External Validation Flow

```
Certificate + Regime → Validate → ValidatedCertificate
                                            │
                                            ▼
                              Kernel decision context
```

### What Receipt Proves About Authority

- Certificate ID used
- But validity must be checked separately
- Replay does NOT verify certificate validity

---

## Replay Results

### Success

| Condition | Result |
|-----------|--------|
| Receipt parses | ✅ |
| State matches | ✅ |
| Decision matches | ✅ |

### Failure

| Condition | Result |
|-----------|--------|
| Malformed receipt | REJECT schemaInvalid |
| State mismatch | REJECT unauthorizedTransition |
| Decision mismatch | REJECT (tampering detected) |
| Trace break | REJECT stateHashLinkFail |

---

## Serialization Format

### JSON Schema for MicroReceipt

```json
{
  "statePrev": {
    "Z": "1.5",
    "vZ": "0.0",
    "I_act": "100.0",
    "W": "0.1",
    "vW": "0.0",
    "I_cd": "50.0"
  },
  "stateNext": {
    "Z": "1.6",
    "vZ": "0.1",
    "I_act": "101.0",
    "W": "0.11",
    "vW": "0.01",
    "I_cd": "51.0"
  },
  "spendAuth": "10.0",
  "defectDeclared": "1.0"
}
```

All QFixed values are serialized as decimal strings.

---

*Last updated: 2026-03-29*
