import CohFusion.Core.State
import CohFusion.Core.Receipt
import CohFusion.Core.Decision

namespace CohFusion.Core

/-- Pure mathematical Coh object class with no crypto assumptions. -/
class CohObject (State Receipt Cost : Type) where
  V      : State → Cost      -- value function
  Spend  : Receipt → Cost    -- authorization spend
  Defect : Receipt → Cost    -- declared defect
  RV     : State → Receipt → Decision  -- runtime verification decision

end CohFusion.Core
