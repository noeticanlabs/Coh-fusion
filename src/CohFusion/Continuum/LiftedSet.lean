/-!
# STATUS: draft

This file is part of the PDE lift layer and is currently incomplete.
It contains abstract signatures for the continuum-to-discrete projection
but lacks formal justification.

See: docs/build_status.md for current classification.
-/
namespace CohFusion.Continuum

/-- Lifted admissible set signatures for MHD stability. -/
structure LiftedSet (State Cost : Type) where
  V_MHD : State → Cost
  K_MHD : State → Prop

end CohFusion.Continuum
