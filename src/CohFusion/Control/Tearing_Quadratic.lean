import CohFusion.Geometry.TearingCore
import Mathlib.Algebra.Ring.Rat

set_option linter.unusedVariables false

namespace CohFusion.Control.Tearing_Quadratic

/-
Tearing Quadratic Synthesis

Constructive synthesis predicates for tearing mode control.

All functions are polymorphic over any type α with sufficient algebraic structure:
Add, Sub, Mul, Neg, HPow, LT, and order relations.
-/

/-- Tearing control gains for current-drive law. -/
structure TearControlGains (α : Type) where
  kW   : α  -- gain on W
  kvW  : α  -- gain on vW
  kI   : α  -- gain on I_cd
  uMax : α  -- saturation limit
  deriving Repr

/-- One-step tearing plant.
    W^{+} = W + dt * v_W
    v_W^{+} = v_W + dt * (-a_W * W - a_vw * v_W + b_cd * u_cd + d_W)
    I_cd^{+} = I_cd + dt * (-a_I * I_cd + u_cd + d_I)
-/
def tearStep [Add α] [Sub α] [Mul α] [Neg α]
    (p : CohFusion.Geometry.Tearing.Params α)
    (s : CohFusion.Geometry.Tearing.StateTear α)
    (dt : α)
    (u_cd d_W d_I : α) :
    CohFusion.Geometry.Tearing.StateTear α :=
  let W_next   := s.W + dt * s.vW
  let vW_next  := s.vW + dt * (-p.nu1 * s.W - p.nu2 * s.vW + u_cd + d_W)
  let I_cd_next := s.I_cd + dt * (-p.nu3 * s.I_cd + u_cd + d_I)
  { W := W_next, vW := vW_next, I_cd := I_cd_next }

/-- Stabilizing Control: Check one-step Lyapunov descent for tearing. -/
def isStabilizing [Add α] [Sub α] [Mul α] [HPow α Nat α] [LT α] [LE α]
    (p : CohFusion.Geometry.Tearing.Params α)
    (dt defect : α)
    (s sNext : CohFusion.Geometry.Tearing.StateTear α)
    (u : α) : Prop :=
  CohFusion.Geometry.Tearing.VgeomTear p sNext ≤
    CohFusion.Geometry.Tearing.VgeomTear p s - u * u * dt + defect

/-- Current-drive law for tearing suppression.
    u_cd = sat(-K_W * W - K_vW * vW - K_I * I_cd)
    Opposes tearing width and growth. -/
def synthesizeQuadratic [Add α] [Neg α] [Mul α] [LT α]
    (g : TearControlGains α)
    (s : CohFusion.Geometry.Tearing.StateTear α) : α :=
  let u_raw := -(g.kW * s.W + g.kvW * s.vW + g.kI * s.I_cd)
  if u_raw > g.uMax then g.uMax
  else if u_raw < -g.uMax then -g.uMax
  else u_raw

end CohFusion.Control.Tearing_Quadratic
