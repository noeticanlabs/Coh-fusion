import CohFusion.Numeric.QFixed
import CohFusion.Geometry.VDECore

namespace CohFusion.Geometry.VDE

open CohFusion.Numeric

/--
  Computable boundary evaluation for VDE.
  G_VDE(z) = M_z(z) - Z_max * I_p(z)
  For the demo, we simplify this to the distance-to-wall.
-/
def compute_m_VDE (p : Params QFixed) (s : StateVDE QFixed) : QFixed :=
  let z_abs := if s.Z < QFixed.zero then QFixed.zero - s.Z else s.Z
  p.Z_wall - z_abs

/-- Evaluates the signed runway for VDE.
    Positive (> 0) means safe; zero (= 0) means boundary; negative (< 0) means wall-touch. -/
def signed_runway_vde (M_z : QFixed) (I_p : QFixed) (Z_max : QFixed) : QFixed :=
  (Z_max * I_p) - M_z

end CohFusion.Geometry.VDE
