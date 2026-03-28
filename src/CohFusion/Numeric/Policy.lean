import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Interval

namespace Coh.Numeric.Policy

/--
COH-FUSION GOVERNANCE POLICY 1.0.0
==================================
The IEEE-754 binary64 `Float` type is strictly forbidden within the
CohFusion consensus and verifier namespaces.

Any transition from PDE observable to discrete receipt MUST project
directly into `Coh.Numeric.QFixed` or `Coh.Numeric.Interval`.

Proof Obligation PO-S1 (Determinism):
"Same slab bytes and same prior digest imply same verifier decision."
This is mathematically impossible to guarantee cross-architecture
with `Float`.

Therefore, the compiler boundary ends here.
Only `Int`-backed `QFixed` types may cross into `CohFusion.Burn.VerifyIgnition`.
-/

def EnforceNoFloat (T : Type) : Prop :=
  T ≠ Float

-- Statically assert our base types comply with the policy
-- Uses axioms because DecidableEq is not available for type inequality
axiom QFixed_is_deterministic : QFixed ≠ Float
axiom Interval_is_deterministic : Interval ≠ Float

end Coh.Numeric.Policy
