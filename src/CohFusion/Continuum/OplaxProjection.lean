namespace CohFusion.Continuum

/-- Oplax projection: PDE-to-ledger soundness bridge. -/
structure OplaxProjection (Cont Disc : Type) where
  toLedger   : Cont → Disc
  soundness  : Prop

end CohFusion.Continuum
