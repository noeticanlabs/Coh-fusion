namespace CohFusion.Continuum

/-- Abstract observable map from plasma state to measurable quantities. -/
/-- Z: observable mapping -/
/-- W_hat: Fourier transform of observable -/
structure Observables (α : Type) where
  Z      : α  -- observable value
  W_hat  : α  -- frequency domain representation
  deriving Repr, DecidableEq

end CohFusion.Continuum
