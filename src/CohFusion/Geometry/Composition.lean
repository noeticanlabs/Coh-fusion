import CohFusion.Geometry.VDE
import CohFusion.Geometry.Tearing

namespace CohFusion.Geometry

/-- Joint VDE + Tearing state for composition. -/
structure StateFus (α : Type) where
  vde  : VDE.StateVDE α
  tear : Tearing.StateTear α
  deriving Repr, DecidableEq

/-- Joint VDE + Tearing parameters. -/
structure ParamsFus (α : Type) where
  vde  : VDE.Params α
  tear : Tearing.Params α
  deriving Repr

/-- Joint geometric functional (VgeomFus) - Additive Public Risk. -/
def VgeomFus [Add α] [Mul α] [HPow α Nat α] (p : ParamsFus α) (s : StateFus α) : α :=
  VDE.VgeomVDE p.vde s.vde + Tearing.VgeomTear p.tear s.tear

/-- Joint disruption predicate: Disjunction of physical disruptions.
    Aligns with Chapter 5 logic where disruption is a physical event in either component. -/
def DisruptedFus [LE α] [Neg α] [Max α] (p : ParamsFus α) (s : StateFus α) : Prop :=
  VDE.DisruptedVDE p.vde s.vde ∨ Tearing.DisruptedTear p.tear s.tear

end CohFusion.Geometry
