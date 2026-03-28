namespace CohFusion.Continuum

/-- Lifted admissible set signatures for MHD stability. -/
structure LiftedSet (State Cost : Type) where
  V_MHD : State → Cost
  K_MHD : State → Prop

end CohFusion.Continuum
