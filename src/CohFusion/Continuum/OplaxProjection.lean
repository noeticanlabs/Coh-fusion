/-!
# STATUS: draft

This file is part of the PDE lift layer and is currently incomplete.
It contains abstract signatures for the continuum-to-discrete projection
but lacks formal justification.

See: docs/build_status.md for current classification.
-/
namespace CohFusion.Continuum

/-- Oplax projection: PDE-to-ledger soundness bridge. -/
structure OplaxProjection (Cont Disc : Type) where
  toLedger   : Cont → Disc
  soundness  : Prop

end CohFusion.Continuum
