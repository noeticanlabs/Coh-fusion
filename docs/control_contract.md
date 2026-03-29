# Control Contract

## Purpose

This document defines the canonical control layer for the Coh-Fusion verifier.
It specifies what hazard channels are modeled, how they are evaluated, and how outputs are handed to the kernel.

---

## Control Layer Responsibility

### Inputs

| Input | Type | Source |
|-------|------|--------|
| Observable state | `State6 QFixed` | Kernel/receipt |
| Control parameters | `ParamsFus QFixed` | Policy |
| Mode | Optional deployment mode | Product layer |

### Outputs

The control layer produces canonical hazard evidence:

| Output | Type | Purpose |
|--------|------|---------|
| VDE risk | `QFixed` | Quadratic risk functional |
| VDE margin | `QFixed` | Threshold slack |
| Tearing risk | `QFixed` | Quadratic risk functional |
| Tearing margin | `QFixed` | Threshold slack |
| Composite risk | `QFixed` | Sum of VDE + Tearing |
| Composite margin | `QFixed` | Minimum channel margin |

### What the Control Layer Does NOT Do

- **Does NOT make final legality decisions**
- **Does NOT validate certificates**
- **Does NOT check affordability**
- All of the above belong to the **kernel layer**

---

## VDE Path

### Geometry Definition

Location: [`src/CohFusion/Geometry/VDECore.lean`](src/CohFusion/Geometry/VDECore.lean)

```lean
-- State
structure StateVDE (α : Type) where
  Z     : α  -- vertical displacement
  vZ    : α  -- vertical velocity
  I_act : α  -- active current

-- Parameters
structure Params (α : Type) where
  omega1     : α  -- frequency component 1
  omega2     : α  -- frequency component 2
  omega3     : α  -- frequency component 3
  Z_wall     : α  -- wall position
  delta_safe : α  -- safe delta margin
  Theta_V    : α  -- VDE threshold
```

### Risk Functional

```lean
def VgeomVDE (p : Params α) (s : StateVDE α) : α :=
  p.omega1 * s.Z^2 + p.omega2 * s.vZ^2 + p.omega3 * s.I_act^2
```

### Disruption Predicate (Squared Form)

```lean
def DisruptedVDE (p : Params α) (s : StateVDE α) : Prop :=
  s.Z^2 ≥ (p.Z_wall - p.delta_safe)^2
```

### Margin

```
margin_VDE = Theta_V - VgeomVDE(p, s)
```

- **Positive**: Safe slack
- **Zero**: At threshold
- **Negative**: Breach (risk exceeds threshold)

---

## Tearing Path

### Geometry Definition

Location: [`src/CohFusion/Geometry/TearingCore.lean`](src/CohFusion/Geometry/TearingCore.lean)

```lean
-- State
structure StateTear (α : Type) where
  W    : α   -- tearing width
  vW   : α   -- tearing growth rate
  I_cd : α  -- current drive

-- Parameters
structure Params (α : Type) where
  nu1     : α  -- first tearing coefficient
  nu2     : α  -- second tearing coefficient
  nu3     : α  -- third tearing coefficient
  W_crit  : α  -- critical flux threshold
  Theta_T : α  -- tearing threshold
```

### Risk Functional

```lean
def VgeomTear (p : Params α) (s : StateTear α) : α :=
  p.nu1 * s.W^2 + p.nu2 * s.vW^2 + p.nu3 * s.I_cd^2
```

### Disruption Predicate (Squared Form)

```lean
def DisruptedTear (p : Params α) (s : StateTear α) : Prop :=
  s.W^2 ≥ p.W_crit^2
```

### Margin

```
margin_Tearing = Theta_T - VgeomTear(p, s)
```

---

## Hazard and Margin Policy

### Sign Convention

| Margin | Meaning |
|--------|---------|
| > 0 | Safe slack |
| = 0 | At boundary |
| < 0 | Breach |

### Risk Value Convention

- Both VDE and Tearing use **quadratic risk functionals**
- Values are **dimensionless** (weighted sums of squared observables)
- Lower is always safer (monotonically increasing risk with state magnitude)

### Composite Summary

```lean
def VgeomFus (p : ParamsFus α) (s : StateFus α) : α :=
  VDE.VgeomVDE p.vde s.vde + Tearing.VgeomTear p.tear s.tear
```

- **Composite risk** = sum of channel risks
- **Composite margin** = minimum of channel margins

---

## Controller Composition

### Composition Law

The wedge uses **conjunctive composition**:

- A transition is safe iff **both** VDE and Tearing are within thresholds
- Failure reporting uses **ordered precedence**

### Failure Ordering

1. State linkage failure
2. VDE threshold breach
3. Tearing threshold breach  
4. Composite breach
5. Oplax violation
6. Other

### Multi-Channel Result Structure

```lean
structure CompositionResult where
  vdeRisk     : QFixed
  vdeMargin   : QFixed
  tearRisk    : QFixed
  tearMargin  : QFixed
  compositeRisk : QFixed
  compositeMargin : QFixed
  vdeSafe     : Bool
  tearSafe    : Bool
  compositeSafe : Bool
```

---

## Architectural Role Separation

### Risk Layer (Control)

| Responsibility | Output |
|---------------|--------|
| Compute VDE risk | VgeomVDE |
| Compute Tearing risk | VgeomTear |
| Compute margins | Threshold slack |
| **NOT**: Final legality | — |

### Certificate Layer (Product)

| Responsibility | Output |
|---------------|--------|
| Validate certificate | ValidatedCertificate |
| Check regime match | regimeFit result |
| **NOT**: Compute risk | — |

### Affordability Layer (Kernel Policy)

| Responsibility | Output |
|---------------|--------|
| Check spend vs budget | Affordability |
| Check defect dominance | Oplax inequality |
| **NOT**: Compute channel risk | — |

### Kernel Layer (Decision)

| Responsibility | Output |
|---------------|--------|
| Combine all inputs | Decision |
| Emit receipt | MicroReceipt |
| **NOT**: Compute channel risk | — |

---

## Control Outputs for Kernel Replay

The kernel needs these from control layer:

| Value | Used For |
|-------|----------|
| `VgeomFus(params, toStateFus(nextState))` | Threshold gate |
| `receipt.defectDeclared` | Defect gate |
| `receipt.spendAuth` | Oplax gate |

Control outputs are **sufficient for kernel replay**.

---

## Proof Status

### Completed Proofs

| File | Status |
|------|--------|
| `Geometry/VDECore.lean` | ✅ Canonical |
| `Geometry/TearingCore.lean` | ✅ Canonical |
| `Control/Theorems/C4B_DissipativeDescent.lean` | ✅ Canonical (ℚ) |
| `Control/Theorems/C4B_VDE.lean` | ✅ Canonical (ℚ) |
| `Control/Theorems/C4B_Tearing.lean` | ✅ Canonical (ℚ) |
| `Geometry/Theorems/C2C_Transversality.lean` | ✅ Canonical (ℚ) |

### Proof Gaps

| File | Status | Action |
|------|--------|--------|
| `Control/VDE_Quadratic.lean` | ⚠️ draft | Theorem pending |

---

## Test Vectors (Expected)

### Nominal

| Input | Expected |
|-------|----------|
| Safe VDE state | margin_VDE > 0, safe |
| Safe Tearing state | margin_Tearing > 0, safe |
| Safe composite | both margins > 0 |

### Edge

| Input | Expected |
|-------|----------|
| At VDE threshold | margin_VDE = 0, safe |
| At Tearing threshold | margin_Tearing = 0, safe |
| Zero margin | boundary case |

### Adversarial

| Input | Expected |
|-------|----------|
| VDE breach | margin_VDE < 0, unsafe |
| Tearing breach | margin_Tearing < 0, unsafe |
| Both breach | composite unsafe |

---

## Assumptions and Limitations

### Assumptions

1. Observable state (Z, vZ, I_act, W, vW, I_cd) is accurately measured
2. Quadratic risk functionals are appropriate proxies for physical danger
3. Thresholds are calibrated correctly

### Limitations

1. Control layer does NOT verify sensor accuracy
2. Control layer does NOT validate certificate validity
3. Risk functionals are conservative bounds, not exact physical measures

---

*Last updated: 2026-03-29*
