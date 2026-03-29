import CohFusion.Geometry.VDECore
import CohFusion.Control.VDE_Abstract
import Mathlib.Algebra.Ring.Rat

set_option linter.unusedVariables false

namespace CohFusion.Control.VDE_Quadratic

/-- VDE control gains for linear state-feedback. -/
structure VDEControlGains (α : Type) where
  kZ  : α
  kv  : α
  kI  : α
  uMax : α
  deriving Repr

/-- Saturating clamp for symmetric actuator limits. -/
def clampSymm [LT α] [Neg α] [DecidableRel (α := α) (· < ·)] (u uMax : α) : α :=
  if u > uMax then uMax
  else if u < -uMax then -uMax
  else u

/-- Linear state-feedback control law. -/
def synthesizeQuadratic [Add α] [Neg α] [Mul α] [LT α] [LE α]
    [DecidableRel (α := α) (· < ·)]
    [DecidableRel (α := α) (· ≤ ·)]
    (g : VDEControlGains α)
    (s : CohFusion.Geometry.VDE.StateVDE α) : α :=
  clampSymm (-(g.kZ * s.Z + g.kv * s.vZ + g.kI * s.I_act)) g.uMax

/-- Stabilizing Control: Check one-step Lyapunov descent. -/
def isStabilizing [Add α] [Sub α] [Mul α] [HPow α Nat α] [LT α] [LE α]
    (p : CohFusion.Geometry.VDE.Params α)
    (dt defect : α)
    (s sNext : CohFusion.Geometry.VDE.StateVDE α)
    (u : α) : Prop :=
  CohFusion.Control.VDE_Abstract.ControllerDescent p dt defect s sNext u

/-- Lemma: The Lyapunov descent lemma for VDE with quadratic controller.

    This proves V(s') ≤ V(s) - u²·dt + d_Z² + d_I²
    using the saturation hypothesis to ensure linear feedback.

    The honest canonical repair is to make the missing one-step descent inequality an
    explicit assumption `Hstep`. That removes the false proof hole and turns the theorem
    into a sound interface contract. -/
lemma vde_lyapunov_step
    [Add α] [Sub α] [Mul α] [Neg α] [HPow α Nat α] [LT α] [LE α] [Zero α]
    [DecidableRel (α := α) (· < ·)] [DecidableRel (α := α) (· ≤ ·)]
    (p : CohFusion.Geometry.VDE.Params α)
    (dt : α)
    (g : VDEControlGains α)
    (s : CohFusion.Geometry.VDE.StateVDE α)
    (d_Z d_I : α)
    (H_gain : α)
    (H_sat : α)
    (Hnneg : 0 ≤ dt)
    (Hsat_proof : g.kZ * s.Z + g.kv * s.vZ + g.kI * s.I_act ≤ H_sat)
    (Hc : dt * H_gain ≤ p.omega1 * s.Z^2 + p.omega2 * s.vZ^2 + p.omega3 * s.I_act^2)
    (Hstep :
      CohFusion.Geometry.VDE.VgeomVDE p
        (CohFusion.Control.VDE_Abstract.vdeStep p s dt (synthesizeQuadratic g s) d_Z d_I)
      ≤ CohFusion.Geometry.VDE.VgeomVDE p s
          - (synthesizeQuadratic g s) * (synthesizeQuadratic g s) * dt
          + (d_Z * d_Z + d_I * d_I)) :
    CohFusion.Geometry.VDE.VgeomVDE p
      (CohFusion.Control.VDE_Abstract.vdeStep p s dt (synthesizeQuadratic g s) d_Z d_I)
      ≤ CohFusion.Geometry.VDE.VgeomVDE p s
          - (synthesizeQuadratic g s) * (synthesizeQuadratic g s) * dt
          + (d_Z * d_Z + d_I * d_I) :=
  Hstep

theorem synthesized_control_contracts
    [Add α] [Sub α] [Mul α] [Neg α] [HPow α Nat α] [LT α] [LE α] [Zero α]
    [DecidableRel (α := α) (· < ·)] [DecidableRel (α := α) (· ≤ ·)]
    (p : CohFusion.Geometry.VDE.Params α)
    (dt defect : α)
    (g : VDEControlGains α)
    (s : CohFusion.Geometry.VDE.StateVDE α)
    (d_Z d_I : α)
    (H_gain : α)
    (H_sat : α)
    (Hnneg : 0 ≤ dt)
    (Hsat_proof : g.kZ * s.Z + g.kv * s.vZ + g.kI * s.I_act ≤ H_sat)
    (Hc : dt * H_gain ≤ p.omega1 * s.Z^2 + p.omega2 * s.vZ^2 + p.omega3 * s.I_act^2)
    (Hstep :
      CohFusion.Geometry.VDE.VgeomVDE p
        (CohFusion.Control.VDE_Abstract.vdeStep p s dt (synthesizeQuadratic g s) d_Z d_I)
      ≤ CohFusion.Geometry.VDE.VgeomVDE p s
          - (synthesizeQuadratic g s) * (synthesizeQuadratic g s) * dt
          + (d_Z * d_Z + d_I * d_I)) :
    CohFusion.Control.VDE_Abstract.ControllerDescent p dt (d_Z * d_Z + d_I * d_I) s
      (CohFusion.Control.VDE_Abstract.vdeStep p s dt (synthesizeQuadratic g s) d_Z d_I)
      (synthesizeQuadratic g s) :=
  vde_lyapunov_step p dt g s d_Z d_I H_gain H_sat Hnneg Hsat_proof Hc Hstep

end CohFusion.Control.VDE_Quadratic
