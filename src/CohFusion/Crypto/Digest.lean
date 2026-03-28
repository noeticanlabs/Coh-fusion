import Mathlib.Data.ByteArray

namespace Coh.Crypto

/--
A canonical 256-bit (32-byte) cryptographic digest.
Used for state_hash, policy_hash, and chain_digest.
-/
structure Digest where
  bytes : ByteArray
  valid_length : bytes.size = 32
  deriving Repr

namespace Digest

/--
Equality of two digests must be strictly byte-for-byte deterministic.
-/
instance : DecidableEq Digest := fun a b =>
  have h_eq : a.bytes = b.bytes ↔ a.bytes.data = b.bytes.data := by rfl
  if h : a.bytes = b.bytes then
    isTrue (by simp [h])
  else
    isFalse (fun h' => by contradiction)

/--
Stub implementation for SHA-256.
In production, this would bind to a deterministic C-FFI.
For now, returns a zeroed 32-byte digest.
-/
def compute_sha256 (data : ByteArray) : ByteArray :=
  ByteArray.mk (Array.mkArray 32 0)

/--
The safe wrapper that enforces the 32-byte guarantee at the type level.
-/
def hash (data : ByteArray) : Digest :=
  let raw_hash := compute_sha256 data
  ⟨raw_hash, rfl⟩

end Digest
end Coh.Crypto
