# Numeric Contract

## Purpose

This document defines the **canonical numeric domain** for the Coh-Fusion verifier kernel.
It is the single source of truth for all arithmetic behavior.

---

## Canonical Numeric Rule

### The Verifier Numeric Domain

> **QFixed** is the canonical numeric domain for the verifier kernel.

All decision-bearing values must be in `QFixed` form:

- Risk values (VgeomVDE, VgeomTear, VgeomFus)
- Thresholds
- Margins
- Defect values
- Spend values
- Affordability comparisons
- Receipt numeric fields

### Non-Canonical Numeric Types

The following are **not** canonical for legality decisions:

| Type | Status | Reason |
|------|--------|--------|
| IEEE-754 Float | ❌ **Banned** | Non-deterministic, platform-dependent |
| Lean `Int` | ⚠️ Adapter-only | Must convert to QFixed before kernel |
| Lean `Rat` (rationals) | ⚠️ Theorem-only | Draft/math layer only |
| Generic `α` | ⚠️ Draft | Must specialize to QFixed for canonical path |

---

## QFixed Semantics

### Representation

| Property | Value |
|----------|-------|
| Format | Q64.64 (fixed-point) |
| Internal storage | Lean `Int` (arbitrary precision) |
| Scale factor | 2^64 = 18446744073709551616 |
| Signedness | Signed (supports negative values) |
| Zero | `⟨0⟩` (canonical) |
| One | `⟨scale⟩` = `⟨18446744073709551616⟩` |

### Canonical Operations

The following operations are canonical for the verifier:

| Operation | Definition | Notes |
|-----------|------------|-------|
| `add` | `⟨a.raw + b.raw⟩` | Exact integer addition |
| `sub` | `⟨a.raw - b.raw⟩` | Exact integer subtraction |
| `mul` | `⟨(a.raw * b.raw) / scale⟩` | 64-bit shift after multiply |
| `div` | `⟨(a.raw * scale) / b.raw⟩` | Inverse multiply with shift |
| `pow n` | `mul a (pow a n)` | Repeated multiply |
| `<` | `a.raw < b.raw` | Integer comparison |
| `≤` | `a.raw ≤ b.raw` | Integer comparison |
| `>` | `b < a` | Derived |
| `≥` | `b ≤ a` | Derived |

### Parsing

**Primary**: `fromDecimalString` — Exact decimal string parser

**Format**: `[+-]?[0-9]+(\.[0-9]+)?`

| Input | Output | Error |
|-------|--------|-------|
| `"1.5"` | `⟨1.5 * 2^64⟩` | — |
| `"-0.25"` | `⟨-0.25 * 2^64⟩` | — |
| `"+3"` | `⟨3 * 2^64⟩` | — |
| `""` | — | `"Empty string"` |
| `"1..5"` | — | `"Invalid format"` |
| `"abc"` | — | `"Invalid integer"` |

### Conversion Boundaries

| From | To | Method | Notes |
|------|-----|--------|-------|
| `String` | QFixed | `fromDecimalString` | Exact, canonical |
| `Int` | QFixed | `fromInt` | Exact, multiplies by scale |
| `Float` | QFixed | **DISALLOWED** | Display only, never for kernel |
| `Rat` | QFixed | Must use `fromDecimalString` | No direct conversion |

**Rule**: No Float values may enter the kernel. Any external numeric data must be parsed via `fromDecimalString`.

---

## Comparison Semantics

### Boundary Semantics (Open Safe Set)

For the verifier kernel, these rules apply:

| Check | Rejection Condition | Acceptance Condition |
|-------|---------------------|----------------------|
| Threshold | `risk > threshold` | `risk ≤ threshold` |
| Defect | `defect > limit` | `defect ≤ limit` |
| Affordability | Via oplax gate | Via oplax gate |

### Equality Behavior

- `a = b` iff `a.raw = b.raw` (exact integer equality)
- Equality at threshold is **accepted** (open set semantics)
- Zero comparison: `a = 0` iff `a.raw = 0`

---

## Failure Semantics

### Overflow Policy

**Decision**: QFixed uses arbitrary-precision `Int` internally, so overflow is **not possible** for typical operations.

However:
- Division by zero: Returns zero (⚠️ should be handled as error)
- Extreme values: No overflow, but precision limited by scale

### Parse Failure Policy

| Failure | Behavior |
|---------|----------|
| Empty string | `Except.error "Empty string"` |
| Invalid format | `Except.error "Invalid format"` |
| Invalid integer | `Except.error "Invalid integer: ..."` |
| Multiple decimal points | `Except.error "Invalid format: multiple decimal points"` |

**Kernel action**: Parse failures should result in immediate **rejection** with appropriate error code.

### Invalid State

- QFixed is a simple wrapper around `Int`
- No invalid states are possible via the public API
- The constructor `mk` is exposed, so invalid states could theoretically be created (via manual construction)

---

## Serialization

### To Receipt

All QFixed values in receipts must serialize as their canonical decimal string form.

### From Receipt

Parse via `fromDecimalString`. Reject if parse fails.

### Replay Guarantee

A QFixed value parsed from a receipt and used in the kernel will produce the **same decision** every time, because:
1. Parsing is deterministic via integer arithmetic
2. Kernel comparisons are exact integer comparisons
3. No floating-point operations are involved

---

## Generic Abstraction Handling

### Current State

Many files use generic `α` type parameters:
- Geometry files: `Params α`, `StateVDE α`, etc.
- Verifier semantics: Generic over `α` with type class constraints

### Rule

For the canonical path, these must be **specialized to QFixed**:

1. `Runtime/VerifierSemanticsQFixed.lean` — ✅ Canonical (already specialized)
2. `Geometry/*` — Must be used with QFixed for kernel
3. `Generic verifyRV` — Draft wrapper only

### Action Required

- Generic `verifyRV` in `VerifierSemantics.lean` should be marked as **draft**
- Only `verifyRV_QFixed` is canonical

---

## Test Expectations

### Boundary Tests

| Test | Expected Behavior |
|------|-------------------|
| Exactly equal to threshold | ACCEPT |
| Exactly equal to defect limit | ACCEPT |
| Exactly zero margin | ACCEPT |
| Just over threshold | REJECT |
| Just over defect limit | REJECT |

### Parse Tests

| Input | Expected |
|-------|----------|
| `"0.0"` | ACCEPT, equals zero |
| `"1.0"` | ACCEPT |
| `"-1.0"` | ACCEPT |
| `""` | REJECT |
| `"1..2"` | REJECT |

### Replay Tests

A value parsed once must produce identical decisions on replay.

---

## Notes

- QFixed provides **deterministic** arithmetic (no platform-dependent behavior)
- The scale (2^64) provides 19 decimal digits of precision
- No Float values may enter the decision path

---

*Last updated: 2026-03-29*
