import CohFusion.Numeric.QFixed
import CohFusion.Geometry.TearingCore

namespace CohFusion.Geometry.Tearing

open CohFusion.Numeric

/-- Computable distance-to-boundary for Tearing. -/
def compute_m_tear (p : Params QFixed) (s : StateTear QFixed) : QFixed :=
  p.W_crit - s.W

/-- Evaluates the signed runway for Tearing modes.
    Positive (> 0) means safe; zero (= 0) means boundary; negative (< 0) means reconnection. -/
def signed_runway_tear (Q_tilde : QFixed) (Q_crit : QFixed) : QFixed :=
  Q_crit - Q_tilde

end CohFusion.Geometry.Tearing
