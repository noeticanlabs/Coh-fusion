/-!
# STATUS: draft

This file is part of the PDE lift layer and is currently incomplete.
It contains abstract signatures for the continuum-to-discrete projection
but lacks formal justification.

See: docs/build_status.md for current classification.
-/
namespace CohFusion.Continuum

/-- Abstract observable signatures for the PDE lift. -/
structure Observables (State Obs : Type) where
  Z     : State → Obs
  W_hat : State → Obs

end CohFusion.Continuum
