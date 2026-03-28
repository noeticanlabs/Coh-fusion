import CohFusion.Numeric
import CohFusion.Crypto
import CohFusion.Base.VerifierResult

namespace Coh.Base

/--
The L1 Mathematical Structure of a Coh Object.
Any domain (plasma fusion, robotics, etc.) must instantiate this exact structure.
-/
class CohObject (X : Type) (R : Type)
  [Coh.Crypto.ToCanonicalBytes X]
  [Coh.Crypto.ToCanonicalBytes R] where

  /--
  V(x): The macroscopic risk functional or faithfulness potential.
  Maps a state strictly to the deterministic QFixed domain.
  -/
  V : X → Coh.Numeric.QFixed

  /--
  Spend(r): The authority, budget, or control effort expended
  during the step documented by the receipt.
  -/
  Spend : R → Coh.Numeric.QFixed

  /--
  Defect(r): The accumulation of error, hardware latency, and
  projection mismatch across the interval.
  -/
  Defect : R → Coh.Numeric.QFixed

  /--
  RV(x, r, x'): The Receipt Verifier.
  A pure, side-effect-free function evaluating the legality of the transition.
  -/
  RV : X → R → X → VerifierResult

end Coh.Base
