import CohFusion.Crypto.Digest
import CohFusion.Crypto.Serialize
import CohFusion.Runtime.HashBoundedReceipt
import Lean.Data.Json

namespace CohFusion.Crypto.Ledger

open Lean

structure BurnReceipt where
  k_index       : Nat
  m_tear_hat    : Float
  m_VDE_hat     : Float
  m_I_hat       : Float
  n_X_hat       : Float
  L_R_hat       : Float
  E_time_hat    : Float
  E_quant_hat   : Float
  E_obs_hat     : Float
  E_model_hat   : Float
  state_digest  : String -- SHA256 Hash of previous state
  deriving Repr, Inhabited, ToJson, FromJson

/--
  Compute digest using HashBoundedReceipt (the canonical path).
  No longer use compute_sha256_mock - that path is deprecated.
  All receipt digests should flow through HashBoundedReceipt.
-/
def computeReceiptDigest [Hasher] [CanonicalSerialize BurnReceipt] (r : BurnReceipt) : String :=
  let digest := Hasher.hashBytes (CanonicalSerialize.toCanonicalBytes r)
  digest.toHexString

end CohFusion.Crypto.Ledger
