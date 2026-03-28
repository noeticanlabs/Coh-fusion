import Lean.Data.Json
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize
import CohFusion.Product.HardwareCertificate
import CohFusion.Crypto.Ledger

namespace CohFusion.Control.BurnContract

open CohFusion.Numeric
open CohFusion.Product
open CohFusion.Crypto.Ledger

/-- Plasma state for burn verification. -/
structure PlasmaState where
  beta        : QFixed
  M_z         : QFixed  -- Vertical Current Moment
  I_p         : QFixed  -- Total Plasma Current
  Q_tilde     : QFixed  -- Signed Tearing Flux
  n_X         : QFixed  -- Certified Drift Norm ||z||_X
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

/-- Observable margins evaluated during the burn check. -/
structure ObservableMargins where
  m_vde  : QFixed
  m_tear : QFixed

/-- Detailed result for the FUS-1 verifier. -/
inductive VerifierResult
  | accept (receipt : BurnReceipt) (digest : String)
  | reject_invalid_envelope (msg : String)
  | reject_unauthorized_transition (msg : String)
  | reject_unaffordable_burn (msg : String)
  | reject_threshold_exceeded (msg : String)
  deriving Repr

end CohFusion.Control.BurnContract
