import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Interval
import CohFusion.Crypto.Serialize

namespace Coh.Numeric

/--
Serialize a QFixed number.
Since QFixed is an Int divided by 2^64, we serialize the raw underlying
exact integer using the Two's Complement Big-Endian packer.
-/
instance : Coh.Crypto.ToCanonicalBytes QFixed where
  toBytes q := Coh.Crypto.intToCanonical q.raw

/--
Serialize an Interval [lower, upper].
Strict concatenation: lower bound bytes followed immediately by upper bound bytes.
-/
instance : Coh.Crypto.ToCanonicalBytes Interval where
  toBytes i :=
    let l_bytes := Coh.Crypto.ToCanonicalBytes.toBytes i.lower
    let u_bytes := Coh.Crypto.ToCanonicalBytes.toBytes i.upper
    l_bytes ++ u_bytes

end Coh.Numeric
