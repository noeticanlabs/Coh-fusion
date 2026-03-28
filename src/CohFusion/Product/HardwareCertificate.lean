import Lean.Data.Json
import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Serialize

namespace CohFusion.Product

open CohFusion.Numeric

/--
  Typed Hardware Certificate for the Coh-Fusion commercial wedge.
  Maps to the `hardware_certificate_schema.json`.
-/
structure HardwareCertificate where
  certificate_id     : String
  hardware_id        : String

  -- Performance & Limits
  latency            : QFixed -- tau_sensor
  observation_error  : QFixed
  slew_limit         : QFixed -- I_dot_max
  saturation_limit   : QFixed -- I_max

  -- Integrity & Governance
  operating_regime_hash : String -- canon_profile_hash
  calibration_epoch     : String -- timestamp of last calibration
  expiry                : String -- not_after

  -- Crypto Root
  root_of_trust      : String
  signature          : String
  deriving Lean.FromJson, Lean.ToJson, Repr, Inhabited

end CohFusion.Product
