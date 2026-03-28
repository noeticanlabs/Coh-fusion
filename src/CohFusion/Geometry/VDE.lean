namespace CohFusion.Geometry.VDE

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
  Theta_V    : α  -- VDE threshold
  deriving Repr

end CohFusion.Geometry.VDE
