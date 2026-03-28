import CohFusion.Crypto.Digest
import CohFusion.Crypto.Serialize

namespace Coh.Crypto.Ledger

/--
The universal Ledger Binding Function.
Takes any type `T` that satisfies the `ToCanonicalBytes` contract,
flattens it, and executes the SHA-256 digest.

This function formally closes PO-S1 (Determinism):
Identical objects -> Identical bytes -> Identical hash.
-/
def hash_object {T : Type} [ToCanonicalBytes T] (obj : T) : Digest :=
  Digest.hash (ToCanonicalBytes.toBytes obj)

end Coh.Crypto.Ledger
