import CohFusion.Crypto.Digest

/-!
# STATUS: excluded from canonical build

This file contains a development-only stub for cryptographic hashing.
It is NOT valid for production chain integrity.

See: docs/build_status.md for current classification.
-/

namespace CohFusion.Crypto

/-- Non-cryptographic development stub. Never valid for production chain integrity. -/
def stubDigest : Digest :=
  { bytes := ByteArray.mk (Array.replicate 32 (UInt8.ofNat 0)) }

/-- Development hasher instance - only for tests and demos. -/
instance : Hasher where
  hashBytes _ := stubDigest

end CohFusion.Crypto

/-
  PRODUCTION NOTE:
  The production hasher namespace is intentionally empty.
  Production builds require an external SHA-256 or BLAKE3 FFI binding.
  Users must provide their own Hasher instance in production.

  Example (when FFI is available):
  ```
  namespace CohFusion.Crypto.Prod
  instance : Hasher where
    hashBytes := blake3_hash
  end CohFusion.Crypto.Prod
  ```
-/
def _proof_placeholder : True := True.intro
