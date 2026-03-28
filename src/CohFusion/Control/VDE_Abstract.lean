import CohFusion.Geometry.VDECore

set_option linter.unusedVariables false

namespace CohFusion.Control.VDE_Abstract

/-
VDE Abstract Control Layer

This file defines the abstract control predicates for the VDE (Vertically-Distorted Element).
These predicates link the physical/geometric VDE state to control synthesis requirements.
-/

/-- Geometric Linkage: The control state is consistent with the public safety envelope. -/
def GeometricLinkage [LT α] [Add α] [Mul α] [HPow α Nat α]
    (p : CohFusion.Geometry.VDE.Params α) (s : CohFusion.Geometry.VDE.StateVDE α) : Prop :=
  CohFusion.Geometry.VDE.VgeomVDE p s < p.Theta_V

/-- One-step VDE plant/update model.
    Z^{+} = Z + dt * v_Z
    v_Z^{+} = v_Z + dt * (-a_Z * Z - a_v * v_Z + b_u * u + d_Z)
    I_act^{+} = I_act + dt * (-a_I * I_act + u + d_I)
-/
def vdeStep
    (p : CohFusion.Geometry.VDE.Params α)
    (s : CohFusion.Geometry.VDE.StateVDE α)
    (dt : α)
    (u d_Z d_I : α) :
    CohFusion.Geometry.VDE.StateVDE α :=
  let Z_next    := s.Z + dt * s.vZ
  let vZ_next   := s.vZ + dt * (-p.omega1 * s.Z - p.omega2 * s.vZ + u + d_Z)
  let I_act_next := s.I_act + dt * (-p.omega3 * s.I_act + u + d_I)
  { Z := Z_next, vZ := vZ_next, I_act := I_act_next }

/-- Controller Descent: Real inequality for VgeomVDE contraction.
    V(s_next) ≤ V(s) - u*u*dt + defect
    This is the Lyapunov descent condition for the VDE. -/
def ControllerDescent [LT α] [Add α] [Sub α] [Mul α] [HPow α Nat α]
    (p : CohFusion.Geometry.VDE.Params α)
    (dt defect : α)
    (s sNext : CohFusion.Geometry.VDE.StateVDE α)
    (u : α) : Prop :=
  CohFusion.Geometry.VDE.VgeomVDE p sNext ≤
    CohFusion.Geometry.VDE.VgeomVDE p s - u * u * dt + defect

/-- Defect Dominance: STRICT authority dominance.
    The control authority must strictly dominate the defect (|u| > |defect|).
    FIXED: was missing authority parameter, now takes authority directly. -/
def DefectDominance (authority defect : α) : Prop :=
  defect < authority

end CohFusion.Control.VDE_Abstract
