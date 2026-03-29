# Kernel Flow

## Operational Overview

This document shows the data flow from inputs to decision in the Coh-Fusion verifier kernel.

---

## Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                         INPUTS                                      │
│  • State6 (prev)        • State6 (next)    • MicroReceipt          │
│  • ParamsFus            • threshold        • defectLimit           │
│  • gamma (oplax factor)                                             │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       ADAPTER LAYER                                 │
│  • Convert raw inputs to kernel types                               │
│  • Validate schema integrity                                        │
│  • Extract margins from state                                       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       KERNEL LAYER                                  │
│                                                                      │
│  Gate 1: State Link                                                 │
│  ─────────────────                                                  │
│  if receipt.statePrev ≠ prevState                                   │
│    → REJECT unauthorizedTransition                                   │
│                                                                      │
│  Gate 2: Threshold                                                  │
│  ─────────────────                                                  │
│  if VgeomFus(params, toStateFus(nextState)) > threshold            │
│    → REJECT thresholdExceeded                                        │
│                                                                      │
│  Gate 3: Defect                                                     │
│  ───────────────                                                    │
│  if receipt.defectDeclared > defectLimit                            │
│    → REJECT defectOutOfBounds                                        │
│                                                                      │
│  Gate 4: Oplax                                                      │
│  ───────────────                                                    │
│  if VgeomFus(next) > VgeomFus(prev) - (1-γ)*spend + defect         │
│    → REJECT oplaxViolation                                          │
│                                                                      │
│  else: ACCEPT                                                        │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       DECISION OUTPUT                               │
│  • Decision.accept  OR  Decision.reject RejectCode                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Entry Points

### Canonical Kernel

| Path | File | Role |
|------|------|------|
| Primary | `Runtime/VerifierSemanticsQFixed.lean` | **Canonical** — QFixed implementation |

### Via Wrapper

| Path | File | Role |
|------|------|------|
| Product | `Product/CommercialWedge.lean` | Calls `verifyRV_QFixed` |
| Bridge | `Runtime/Bridge.lean` | Calls `verifyRV` in loop |

### Legacy/Adapter

| Path | File | Role |
|------|------|------|
| Demo | `Control/BurnPolicyDemo.lean` | **Must be refactored** — currently bypasses kernel |

---

## Decision Flow Summary

```
Inputs
   │
   ▼
[Adapter] ──► Kernel ──► Decision
   │           │
   │           ├── State Link Gate
   │           ├── Threshold Gate  
   │           ├── Defect Gate
   │           └── Oplax Gate
   │
   ▼
 Receipt + Digest (if accepted)
```

---

## Notes

- All gates use **open set** semantics (`>` for rejection)
- Failure order is fixed: State → Threshold → Defect → Oplax
- No branching decision paths within the kernel

---

*Last updated: 2026-03-29*
