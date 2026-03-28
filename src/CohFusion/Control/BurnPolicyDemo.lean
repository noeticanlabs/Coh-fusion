import CohFusion.Control.BurnContract
import CohFusion.Geometry.VDERuntime
import CohFusion.Geometry.TearingRuntime
import CohFusion.Product.HardwareCertificate
import CohFusion.Crypto.Digest
import CohFusion.Crypto.Serialize
import CohFusion.Crypto.Ledger

namespace CohFusion.Control.BurnPolicyDemo

open CohFusion.Numeric
open CohFusion.Product
open CohFusion.Control.BurnContract
open CohFusion.Crypto

/-- Real parameter object for burn policy (replaces MOCK_* constants). -/
structure BurnPolicyParams where
  zMax           : QFixed
  qCrit          : QFixed
  slewConstant    : QFixed
  lagPenalty     : QFixed
  sensorScale    : QFixed
  lipschitzScale : QFixed
  deriving Repr

/-- Default burn policy parameters. -/
def defaultBurnPolicyParams : BurnPolicyParams :=
  { zMax         := QFixed.fromDecimalString "2.5".toExcept.get!
  , qCrit        := QFixed.fromDecimalString "0.8".toExcept.get!
  , slewConstant  := QFixed.fromDecimalString "50.0".toExcept.get!
  , lagPenalty   := QFixed.fromDecimalString "2.5".toExcept.get!
  , sensorScale   := QFixed.fromDecimalString "100.0".toExcept.get!
  , lipschitzScale := QFixed.fromDecimalString "1.5".toExcept.get! }

/-- Step 1: Evaluate observable margins. -/
def evaluateObservableMargins (params : BurnPolicyParams) (state : PlasmaState) : ObservableMargins :=
  { m_vde  := CohFusion.Geometry.VDE.signed_runway_vde state.M_z state.I_p params.zMax,
    m_tear := CohFusion.Geometry.Tearing.signed_runway_tear state.Q_tilde params.qCrit }

/-- Step 2: Compute burn defect with proper decomposition.
    E_burn = E_model + E_act + E_sensor -/
def computeBurnDefect
    (params : BurnPolicyParams)
    (cert : HardwareCertificate)
    (state : PlasmaState)
    (margins : ObservableMargins) :
    (QFixed × QFixed × QFixed) :=  -- returns (E_model, E_act, E_sensor)
  let delta_active := if margins.m_vde < margins.m_tear then margins.m_vde else margins.m_tear

  -- E_act: actuation defect from slew/saturation shortfall
  let E_act :=
    if delta_active ≤ QFixed.zero then
      QFixed.fromDecimalString "999999".toExcept.get! -- Boundary breached
    else
      let I_dot_req := params.slewConstant / (delta_active * delta_active)
      if I_dot_req > cert.slew_limit then
        params.lagPenalty * (I_dot_req - cert.slew_limit)
      else
        QFixed.zero

  -- E_sensor: sensor latency + observation error
  let E_sensor := cert.latency * params.sensorScale

  -- E_model: Lipschitz-style residual from model mismatch
  let E_model := params.lipschitzScale * state.M_z * state.M_z

  (E_model, E_act, E_sensor)

/-- Step 3: Check affordability (STRICT DOMINANCE per spec).
    defect < authority (not ≤). -/
def checkAffordability (defect : QFixed) (authority : QFixed) : Bool :=
  defect < authority

/-- Step 4: Build burn receipt with CORRECT field bindings.
    FIXED: was previously assigning eModel := E_act (WRONG!) -/
def buildBurnReceipt
    (_state : PlasmaState)
    (margins : ObservableMargins)
    (E_model : QFixed)
    (E_act : QFixed)
    (E_sensor : QFixed)
    (dt eta_avail spend : QFixed)
    (cert_id : String) : BurnReceipt :=
  { dt           := dt,
    etaAvailable := eta_avail,
    spend        := spend,
    eModel       := E_model,  -- FIXED: was E_act
    eAct         := E_act,
    eSensor      := E_sensor,
    margins      := margins,
    certificateId := cert_id }

/-- Step 5: Bind receipt digest with proper chain binding.
    Omega_{k+1} = H(Omega_k || serialize(r_k) || root_of_trust) -/
structure BurnChainInput where
  prevDigest   : String
  receipt    : BurnReceipt
  rootOfTrust : String

instance : CanonicalSerialize BurnChainInput where
  toCanonicalBytes bci :=
    let prevBytes := bci.prevDigest.toList.map UInt8.ofNat
    let receiptBytes := CanonicalSerialize.toCanonicalBytes bci.receipt
    let rootBytes := bci.rootOfTrust.toList.map UInt8.ofNat
    ByteArray.mk (prevBytes ++ receiptBytes.toList ++ rootBytes)

def bindReceiptDigest [Hasher] (prevDigest : String) (receipt : BurnReceipt) (rootOfTrust : String) : String :=
  let input : BurnChainInput := { prevDigest := prevDigest, receipt := receipt, rootOfTrust := rootOfTrust }
  let digest := Hasher.hashBytes (CanonicalSerialize.toCanonicalBytes input)
  digest.toHexString

/--
  Integrated verifyIgnition (v3) using the staged pipeline.
-/
def verifyIgnition_v3
    (cert : HardwareCertificate)
    (state : PlasmaState)
    (dt : QFixed)
    (eta_avail : QFixed)
    (prev_digest : String)
    : VerifierResult :=
  let params := defaultBurnPolicyParams
  let margins := evaluateObservableMargins params state
  let (E_model, E_act, E_sensor) := computeBurnDefect params cert state margins
  let E_burn := E_model + E_act + E_sensor
  let authority := eta_avail * dt
  let spend := authority

  if ¬(checkAffordability E_burn authority) then
    VerifierResult.reject_unaffordable_burn s!"REJECT_UNAFFORDABLE_BURN"
  else
    let receipt := buildBurnReceipt state margins E_model E_act E_sensor dt eta_avail spend cert.certificateId
    let digest := bindReceiptDigest prev_digest receipt cert.root_of_trust
    VerifierResult.accept receipt digest

end CohFusion.Control.BurnPolicyDemo
