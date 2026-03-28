import CohFusion.Numeric
import CohFusion.Base.CohObject
import CohFusion.Base.VerifierResult

namespace Coh.Base.Obligations

/--
Proof Obligation PO-S3: Oplax Aggregation Law
For any legally accepted transition, the ending risk plus the budget spent
must be less than or equal to the starting risk plus the tolerated hardware defect.

If a plasma controller cannot mathematically prove this proposition,
it is rejected from the canon.
-/
def is_oplax_sound
  {X : Type} {R : Type}
  [Coh.Crypto.ToCanonicalBytes X]
  [Coh.Crypto.ToCanonicalBytes R]
  [Coh.Base.CohObject X R]
  (x : X) (r : R) (x_next : X) : Prop :=

  let v_curr := Coh.Base.CohObject.V x
  let v_next := Coh.Base.CohObject.V x_next
  let spend  := Coh.Base.CohObject.Spend r
  let defect := Coh.Base.CohObject.Defect r

  -- The core thermodynamic governance inequality
  (Coh.Base.CohObject.RV x r x_next = Coh.Base.VerifierResult.ACCEPT) →
  (v_next + spend ≤ v_curr + defect)

end Coh.Base.Obligations
