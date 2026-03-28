namespace CohFusion.Continuum

/-- Oplax projection: PDE-to-ledger soundness bridge at theorem-interface level. -/
/-- This file contains typed reduction interfaces, NOT PDE proofs. -/

/-- Project continuous state to discrete ledger representation. -/
structure OplaxProjection (α β : Type) where
  toLedger : α → β  -- projection function
  soundnessLemma : Prop  -- placeholder for soundness proof
  deriving Repr

end CohFusion.Continuum
