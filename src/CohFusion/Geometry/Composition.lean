import CohFusion.Geometry.VDECore
import CohFusion.Geometry.TearingCore
import CohFusion.Core.State

namespace CohFusion.Geometry

open CohFusion.Core

/-- Joint VDE + Tearing state for composition. -/
structure StateFus (α : Type) where
  vde  : VDE.StateVDE α
  tear : Tearing.StateTear α
  deriving Repr, DecidableEq

/-- Mapping from flat State6 to Geometry.StateFus -/
def toStateFus {α : Type} (s : State6 α) : StateFus α :=
  { vde  := { Z := s.Z, vZ := s.vZ, I_act := s.I_act }
    tear := { W := s.W, vW := s.vW, I_cd := s.I_cd } }

/-- Joint VDE + Tearing parameters. -/
structure ParamsFus (α : Type) where
  vde  : VDE.Params α
  tear : Tearing.Params α
  deriving Repr

/-- Joint geometric functional (VgeomFus) - Additive Public Risk. -/
def VgeomFus [Add α] [Mul α] [HPow α Nat α] (p : ParamsFus α) (s : StateFus α) : α :=
  VDE.VgeomVDE p.vde s.vde + Tearing.VgeomTear p.tear s.tear

/--
  Joint disruption predicate: Disjunction of physical disruptions.
  Aligns with Chapter 5 logic where disruption is a physical event in either component.

  Uses squared form from core geometry to avoid sign/abs issues in theorem layer.
-/
def DisruptedFus {α : Type} [Add α] [Sub α] [Mul α] [HPow α Nat α] [LE α] (p : ParamsFus α) (s : StateFus α) : Prop :=
  VDE.DisruptedVDE p.vde s.vde ∨ Tearing.DisruptedTear p.tear s.tear

end CohFusion.Geometry
