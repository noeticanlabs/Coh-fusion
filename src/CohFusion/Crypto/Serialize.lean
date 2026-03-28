import Mathlib.Data.ByteArray
import Mathlib.Data.UInt
import CohFusion.Numeric.QFixed

namespace Coh.Crypto

/--
The strict serialization contract.
Any object claiming to be a Coh state or receipt must implement this.
Order of fields matters; padding is strictly forbidden.
-/
class ToCanonicalBytes (α : Type) where
  toBytes : α → ByteArray

-- ==========================================
-- Base Type Serialization
-- ==========================================

/--
Unsigned 8-bit integer serialization (Base Case)
-/
instance : ToCanonicalBytes UInt8 where
  toBytes x := ByteArray.mk #[x]

/--
Unsigned 64-bit integer serialization (Big-Endian network byte order).
Strict bit-shifting to prevent endian-drift on different OS architectures.
-/
instance : ToCanonicalBytes UInt64 where
  toBytes x :=
    let b1 := (x >>> 56).toUInt8
    let b2 := ((x >>> 48) &&& 0xFF).toUInt8
    let b3 := ((x >>> 40) &&& 0xFF).toUInt8
    let b4 := ((x >>> 32) &&& 0xFF).toUInt8
    let b5 := ((x >>> 24) &&& 0xFF).toUInt8
    let b6 := ((x >>> 16) &&& 0xFF).toUInt8
    let b7 := ((x >>> 8) &&& 0xFF).toUInt8
    let b8 := (x &&& 0xFF).toUInt8
    ByteArray.mk #[b1, b2, b3, b4, b5, b6, b7, b8]

/--
Signed 64-bit integer serialization.
We cast to UInt64 to preserve exact two's complement bit representation,
then rely on the strict Big-Endian packer above.
-/
def intToCanonical (x : Int) : ByteArray :=
  let as_uint := x.toUInt64
  ToCanonicalBytes.toBytes as_uint

end Coh.Crypto
