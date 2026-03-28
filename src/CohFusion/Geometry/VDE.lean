import CohFusion.Numeric.QFixed

namespace CohFusion.Geometry.VDE

open CohFusion.Numeric

/-- VDE (Vertically-Distorted Element) state for finite-dimensional wedge geometry. -/
structure StateVDE (α : Type) where
  Z     : α  -- vertical displacement
  vZ    : α  -- vertical velocity
  I_act : α  -- active current
  deriving Repr, DecidableEq

/-- VDE parameters for six-parameter quadratic synthesis. -/
structure Params (α : Type) where
  omega1     : α  -- first frequency component
  omega2     : α  -- second frequency component
  omega3     : α  -- third frequency component
  Z_wall     : α  -- wall position
  delta_safe : α  -- safe delta margin
  Theta_V    : α  -- VDE threshold for public safety envelope
  deriving Repr

/-- Geometric VDE functional (Vgeom) - Public Risk Functional. -/
def VgeomVDE [Add α] [Mul α] [HPow α Nat α] (p : Params α) (s : StateVDE α) : α :=
  p.omega1 * s.Z^2 + p.omega2 * s.vZ^2 + p.omega3 * s.I_act^2

/--
  Computable boundary evaluation for VDE.
  G_VDE(z) = M_z(z) - Z_max * I_p(z)
  For the demo, we simplify this to the distance-to-wall.
-/
def compute_m_VDE (p : Params QFixed) (s : StateVDE QFixed) : QFixed :=
  let z_abs := if s.Z < QFixed.zero then QFixed.zero - s.Z else s.Z
  p.Z_wall - z_abs

/-- Evaluates G_VDE(z) = M_z - Z_max * I_p.
    Positive margin means safe; negative means wall-touch. -/
def evaluate_margin (M_z : QFixed) (I_p : QFixed) (Z_max : QFixed) : QFixed :=
  let G_VDE := M_z - (Z_max * I_p)
  QFixed.zero - G_VDE

/-- Disruption predicate: Physical wall touch condition.
    In the VDE case, this is usually defined by the vertical displacement exceeding the wall position. -/
def DisruptedVDE [LE α] [Neg α] [Max α] (p : Params α) (s : StateVDE α) : Prop :=
  (max s.Z (-s.Z)) ≥ p.Z_wall

end CohFusion.Geometry.VDE
