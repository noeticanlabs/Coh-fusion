import CohFusion.Runtime.VerifierSemanticsQFixed
import CohFusion.Numeric.QFixed
import CohFusion.Core.Receipt
import CohFusion.Core.Decision

namespace Tests.Kernel

/--
  Kernel decision tests.

  The canonical kernel (verifyRV_QFixed) uses this decision ordering:
  1. State Link Gate → unauthorizedTransition
  2. Threshold Gate → thresholdExceeded
  3. Defect Gate → defectOutOfBounds
  4. Oplax Gate → oplaxViolation
  5. Accept
--/

open CohFusion.Core
open CohFusion.Numeric
open CohFusion.Runtime
open CohFusion.Geometry

/-- Test: Accept path - valid inputs produce accept -/
#eval do
  let p : ParamsFus QFixed :=
    { omega1 := ⟨1⟩, omega2 := ⟨1⟩, omega3 := ⟨1⟩,
      nu1 := ⟨1⟩, nu2 := ⟨1⟩, nu3 := ⟨1⟩ }
  let st : State6 QFixed :=
    { Z := ⟨0⟩, vZ := ⟨0⟩, I_act := ⟨0⟩,
      W := ⟨0⟩, vW := ⟨0⟩, I_cd := ⟨0⟩ }
  let r : MicroReceipt QFixed :=
    { statePrev := st,
      stateNext := st,
      spendAuth := ⟨18446744073709551616⟩,
      defectDeclared := ⟨0⟩ }
  let threshold := ⟨18446744073709551616⟩
  let defectLimit := ⟨18446744073709551616⟩
  let gamma := ⟨0⟩

  let result := verifyRV_QFixed p r st threshold defectLimit gamma
  IO.println s!"Accept test: {result.repr}"
  pure ()

/-- Test: Reject - unauthorizedTransition -/
#eval do
  let p : ParamsFus QFixed :=
    { omega1 := ⟨1⟩, omega2 := ⟨1⟩, omega3 := ⟨1⟩,
      nu1 := ⟨1⟩, nu2 := ⟨1⟩, nu3 := ⟨1⟩ }
  let expected : State6 QFixed :=
    { Z := ⟨0⟩, vZ := ⟨0⟩, I_act := ⟨0⟩,
      W := ⟨0⟩, vW := ⟨0⟩, I_cd := ⟨0⟩ }
  let wrong : State6 QFixed :=
    { Z := ⟨1⟩, vZ := ⟨0⟩, I_act := ⟨0⟩,
      W := ⟨0⟩, vW := ⟨0⟩, I_cd := ⟨0⟩ }
  let r : MicroReceipt QFixed :=
    { statePrev := wrong,
      stateNext := expected,
      spendAuth := ⟨0⟩,
      defectDeclared := ⟨0⟩ }
  let threshold := ⟨18446744073709551616⟩
  let defectLimit := ⟨18446744073709551616⟩
  let gamma := ⟨0⟩

  let result := verifyRV_QFixed p r expected threshold defectLimit gamma
  IO.println s!"Unauthorized test: {result.repr}"
  pure ()

/-- Test: Reject - thresholdExceeded -/
#eval do
  let p : ParamsFus QFixed :=
    { omega1 := ⟨1⟩, omega2 := ⟨1⟩, omega3 := ⟨1⟩,
      nu1 := ⟨1⟩, nu2 := ⟨1⟩, nu3 := ⟨1⟩ }
  let st : State6 QFixed :=
    { Z := ⟨0⟩, vZ := ⟨0⟩, I_act := ⟨0⟩,
      W := ⟨0⟩, vW := ⟨0⟩, I_cd := ⟨0⟩ }
  let high : State6 QFixed :=
    { Z := ⟨18446744073709551616⟩, vZ := ⟨0⟩, I_act := ⟨0⟩,
      W := ⟨0⟩, vW := ⟨0⟩, I_cd := ⟨0⟩ }
  let r : MicroReceipt QFixed :=
    { statePrev := st,
      stateNext := high,
      spendAuth := ⟨0⟩,
      defectDeclared := ⟨0⟩ }
  let threshold := ⟨0⟩
  let defectLimit := ⟨18446744073709551616⟩
  let gamma := ⟨0⟩

  let result := verifyRV_QFixed p r st threshold defectLimit gamma
  IO.println s!"Threshold test: {result.repr}"
  pure ()

/-- Test: Reject - defectOutOfBounds -/
#eval do
  let p : ParamsFus QFixed :=
    { omega1 := ⟨1⟩, omega2 := ⟨1⟩, omega3 := ⟨1⟩,
      nu1 := ⟨1⟩, nu2 := ⟨1⟩, nu3 := ⟨1⟩ }
  let st : State6 QFixed :=
    { Z := ⟨0⟩, vZ := ⟨0⟩, I_act := ⟨0⟩,
      W := ⟨0⟩, vW := ⟨0⟩, I_cd := ⟨0⟩ }
  let r : MicroReceipt QFixed :=
    { statePrev := st,
      stateNext := st,
      spendAuth := ⟨0⟩,
      defectDeclared := ⟨1⟩ }
  let threshold := ⟨18446744073709551616⟩
  let defectLimit := ⟨0⟩
  let gamma := ⟨0⟩

  let result := verifyRV_QFixed p r st threshold defectLimit gamma
  IO.println s!"Defect test: {result.repr}"
  pure ()

/-- Test: Boundary - exact threshold equality -/
#eval do
  let p : ParamsFus QFixed :=
    { omega1 := ⟨1⟩, omega2 := ⟨1⟩, omega3 := ⟨1⟩,
      nu1 := ⟨1⟩, nu2 := ⟨1⟩, nu3 := ⟨1⟩ }
  let st : State6 QFixed :=
    { Z := ⟨0⟩, vZ := ⟨0⟩, I_act := ⟨0⟩,
      W := ⟨0⟩, vW := ⟨0⟩, I_cd := ⟨0⟩ }
  let r : MicroReceipt QFixed :=
    { statePrev := st,
      stateNext := st,
      spendAuth := ⟨0⟩,
      defectDeclared := ⟨0⟩ }
  let threshold := ⟨0⟩
  let defectLimit := ⟨18446744073709551616⟩
  let gamma := ⟨0⟩

  let result := verifyRV_QFixed p r st threshold defectLimit gamma
  IO.println s!"Boundary test: {result.repr}"
  pure ()

end Tests.Kernel
