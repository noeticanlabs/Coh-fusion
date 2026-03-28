import CohFusion.Geometry.Composition

set_option linter.unusedVariables false

namespace CohFusion.Control.Composition

/-
Joint Control Composition

This file defines the joint control predicates for the coupled VDE + Tearing system.
-/

/-- Joint control: combines VDE and tearing control inputs. -/
structure JointControl (α : Type) where
  uVDE   : α  -- VDE control input
  uTear  : α  -- tearing control input
  deriving Repr, DecidableEq

/-- Joint Geometric Linkage: Both components are within their respective safety envelopes. -/
def JointGeometricLinkage [LT α] [Add α] [Mul α] [HPow α Nat α]
    (p : CohFusion.Geometry.ParamsFus α) (s : CohFusion.Geometry.StateFus α) : Prop :=
  CohFusion.Geometry.VDE.VgeomVDE p.vde s.vde < p.vde.Theta_V ∧
  CohFusion.Geometry.Tearing.VgeomTear p.tear s.tear < p.tear.Theta_T

/-- Joint controller descent: Additive oplax composition.
    V_fus(s+) ≤ V_fus(s) - (1-γ)*(spend_VDE + spend_tear) + defect + coupling_slack
    At v1, channels are decoupled (coupling_slack = 0).
-/
def JointControllerDescent
    (p : CohFusion.Geometry.ParamsFus α)
    (s sNext : CohFusion.Geometry.StateFus α)
    (c : JointControl α)
    (spend defect gamma couplingSlack : α) : Prop :=
  CohFusion.Geometry.VgeomFus p sNext ≤
    CohFusion.Geometry.VgeomFus p s - (CohFusion.Numeric.QFixed.one - gamma) * spend + defect + couplingSlack

end CohFusion.Control.Composition
