namespace CohFusion.Continuum

/-- Lifted admissible set signatures for MHD stability. -/
/-- V_MHD: admissible set for MHD dynamics -/
/-- K_MHD: confinement region -/
structure LiftedSet (α : Type) where
  V_MHD : α  -- MHD admissible set
  K_MHD : α  -- MHD confinement region
  deriving Repr, DecidableEq

end CohFusion.Continuum
