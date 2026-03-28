import CohFusion.Control.BurnContract
namespace CohFusion.Crypto

/-- Canonical byte serialization interface. -/
class CanonicalSerialize (α : Type) where
  toCanonicalBytes : α → ByteArray

/-- Canonical serialization for BurnReceipt.
    Includes all receipt fields for deterministic hashing. -/
instance : CanonicalSerialize CohFusion.Control.BurnContract.BurnReceipt where
  toCanonicalBytes r :=
    let dtBytes := r.dt.raw.repr.toList.map UInt8.ofNat
    let etaAvailBytes := r.etaAvailable.raw.repr.toList.map UInt8.ofNat
    let spendBytes := r.spend.raw.repr.toList.map UInt8.ofNat
    let eModelBytes := r.eModel.raw.repr.toList.map UInt8.ofNat
    let eActBytes := r.eAct.raw.repr.toList.map UInt8.ofNat
    let eSensorBytes := r.eSensor.raw.repr.toList.map UInt8.ofNat
    let mVdeBytes := r.margins.m_vde.raw.repr.toList.map UInt8.ofNat
    let mTearBytes := r.margins.m_tear.raw.repr.toList.map UInt8.ofNat
    let certIdBytes := r.certificateId.toList.map UInt8.ofNat
    ByteArray.mk (dtBytes ++ etaAvailBytes ++ spendBytes ++ eModelBytes ++ eActBytes ++ eSensorBytes ++ mVdeBytes ++ mTearBytes ++ certIdBytes)

end CohFusion.Crypto
