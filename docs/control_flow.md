# Control Flow

## Operational Overview

This document shows how control inputs become hazard evidence for the kernel.

---

## Control Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    OBSERVABLE STATE                                  │
│                                                                      │
│  State6 (QFixed):                                                   │
│  • Z (vertical displacement)                                        │
│  • vZ (vertical velocity)                                           │
│  • I_act (active actuator)                                          │
│  • W (tearing width)                                                │
│  • vW (tearing growth rate)                                         │
│  • I_cd (current drive)                                             │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    VDE CHANNEL                                       │
│                                                                      │
│  Input: StateVDE from State6                                         │
│  Compute: VgeomVDE = ω1*Z² + ω2*vZ² + ω3*I_act²                    │
│  Margin: Theta_V - VgeomVDE                                          │
│                                                                      │
│  Output: { risk, margin, safe }                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    TEARING CHANNEL                                    │
│                                                                      │
│  Input: StateTear from State6                                        │
│  Compute: VgeomTear = ν1*W² + ν2*vW² + ν3*I_cd²                     │
│  Margin: Theta_T - VgeomTear                                         │
│                                                                      │
│  Output: { risk, margin, safe }                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    COMPOSITION                                         │
│                                                                      │
│  Combine:                                                            │
│  • compositeRisk = VgeomVDE + VgeomTear                             │
│  • compositeMargin = min(margin_VDE, margin_Tearing)                │
│  • compositeSafe = safe_VDE ∧ safe_Tearing                           │
│                                                                      │
│  Output: CompositionResult                                           │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    KERNEL HANDOFF                                     │
│                                                                      │
│  Kernel uses:                                                        │
│  • compositeRisk (for threshold gate)                               │
│  • receipt.defectDeclared (for defect gate)                         │
│  • receipt.spendAuth (for oplax gate)                                │
│                                                                      │
│  Control does NOT make final decision                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Channel Evaluation

### VDE Evaluation

```lean
-- Compute risk
let risk_VDE := VgeomVDE p.vde (toStateVDE s)

-- Compute margin  
let margin_VDE := p.Theta_V - risk_VDE

-- Determine safety
let safe_VDE := margin_VDE > 0  -- positive margin = safe
```

### Tearing Evaluation

```lean
-- Compute risk
let risk_Tear := VgeomTear p.tear (toStateTear s)

-- Compute margin
let margin_Tear := p.Theta_T - risk_Tear

-- Determine safety
let safe_Tear := margin_Tear > 0
```

### Composite

```lean
-- Sum of risks
let compositeRisk := risk_VDE + risk_Tear

-- Minimum margin (both must be safe)
let compositeMargin := min margin_VDE margin_Tear

-- Conjunction
let compositeSafe := safe_VDE && safe_Tear
```

---

## Disruption Predicates

### VDE Disruption (Squared Form)

```lean
def DisruptedVDE (p : Params α) (s : StateVDE α) : Prop :=
  s.Z^2 ≥ (p.Z_wall - p.delta_safe)^2
```

- **Trigger**: Vertical displacement exceeds safe wall proximity

### Tearing Disruption (Squared Form)

```lean
def DisruptedTear (p : Params α) (s : StateTear α) : Prop :=
  s.W^2 ≥ p.W_crit^2
```

- **Trigger**: Tearing mode width exceeds critical threshold

---

## Role Separation

```
┌──────────────────────────────────────────────────────┐
│ Layer           │ Owns                  │ Does NOT    │
├─────────────────┼───────────────────────┼─────────────┤
│ Control         │ Hazard computation    │ Final       │
│                 │ (VDE, Tearing, margins) │ legality   │
├─────────────────┼───────────────────────┼─────────────┤
│ Certificate     │ Regime validation     │ Hazard      │
│                 │                       │ computation │
├─────────────────┼───────────────────────┼─────────────┤
│ Kernel Policy   │ Affordability check   │ Hazard      │
│                 │                       │ computation  │
├─────────────────┼───────────────────────┼─────────────┤
│ Kernel          │ Final decision        │ Hazard      │
│                 │                       │ computation │
└──────────────────────────────────────────────────────┘
```

---

## Failure Reporting

When multiple channels fail, report in order:

1. State linkage (if applicable)
2. VDE breach
3. Tearing breach
4. Composite breach
5. Oplax violation
6. Other

---

*Last updated: 2026-03-29*
