import CohFusion.Core.CohObject
import CohFusion.Core.Receipt

namespace CohFusion.Core

variable {State Receipt Cost : Type}
variable [LE Cost] [Sub Cost] [Add Cost]

/-- Oplax soundness: V(next) ≤ V(prev) - Spend + Defect -/
def isOplaxSound
    (V : State → Cost)
    (Spend : Receipt → Cost)
    (Defect : Receipt → Cost)
    (step : State → Receipt → State)
    : Prop :=
  ∀ s r, V (step s r) ≤ V s - Spend r + Defect r

/-- Valid trace: all decisions accept -/
def ValidTrace
    (RV : State → Receipt → Decision)
    (step : State → Receipt → State)
    : State → List Receipt → Prop
  | _, [] => True
  | anchor, r :: rs =>
      RV anchor r = Decision.accept ∧
      ValidTrace RV step (step anchor r) rs

/-- Threshold safety: defect below threshold -/
def isThresholdSafe
    (Defect : Receipt → Cost)
    (threshold : Cost)
    (r : Receipt)
    : Prop :=
  Defect r ≤ threshold

/-- Defect admissibility: defect within bounds -/
def isDefectAdmissible
    (Defect : Receipt → Cost)
    (maxDefect : Cost)
    (r : Receipt)
    : Prop :=
  Defect r ≤ maxDefect

end CohFusion.Core
