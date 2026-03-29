import CohFusion.Core.State
import CohFusion.Crypto.Digest

namespace CohFusion.Core

/-- Micro-receipt for a single control step. -/
@[deprecated "Use FusionReceipt instead" ]
structure MicroReceipt (α : Type) where
  statePrev      : State6 α
  stateNext      : State6 α
  spendAuth      : α
  defectDeclared : α
  deriving Repr, DecidableEq

/-- Slab receipt for a batch of steps (telescoping path). -/
@[deprecated "Use FusionReceipt instead" ]
structure SlabReceipt (α : Type) where
  statePrev      : State6 α
  stateNext      : State6 α
  totalSpend     : α
  totalDefect    : α
  stepCount      : Nat
  deriving Repr, DecidableEq

/-- FusionReceipt: unified receipt type combining all receipt variants.

## Fields:
- `schemaId`: Unique identifier for receipt schema version
- `version`: Schema version for compatibility tracking
- `statePrev`: Previous state (State6) for state linkage
- `stateNext`: Next state (State6) for state transition
- `spendAuth`: Authorization spend for this step/batch
- `defectDeclared`: Declared defect for this step/batch
- `stepCount`: Number of steps in batch (for telescoping)
- `digest`: Optional digest/hash for chain binding
- `policyId`: Policy reference identifier
- `canonId`: Canon/certificate reference identifier
- `prevClaim`: Optional claim hash linking to previous receipt
- `nextClaim`: Optional claim hash for next receipt linking
-/
structure FusionReceipt (α : Type) where
  schemaId      : String          -- Schema identifier
  version       : Nat             -- Schema version
  statePrev     : State6 α        -- Previous state
  stateNext     : State6 α        -- Next state
  spendAuth     : α               -- Authorization spend
  defectDeclared : α             -- Declared defect
  stepCount     : Nat             -- Step count (1 for single-step)
  digest        : Option Digest    -- Optional digest for chain binding
  policyId      : Option String   -- Policy reference
  canonId       : Option String   -- Canon/certificate reference
  prevClaim     : Option Digest  -- Previous receipt claim (hash linking)
  nextClaim     : Option Digest  -- Next receipt claim (for chaining)
  deriving Repr, DecidableEq

/-- Create a FusionReceipt from a MicroReceipt.
-/
def FusionReceipt.ofMicroReceipt [Inhabited Digest] (schemaId : String) (version : Nat)
    (micro : MicroReceipt α) : FusionReceipt α :=
  { schemaId := schemaId
    version := version
    statePrev := micro.statePrev
    stateNext := micro.stateNext
    spendAuth := micro.spendAuth
    defectDeclared := micro.defectDeclared
    stepCount := 1
    digest := none
    policyId := none
    canonId := none
    prevClaim := none
    nextClaim := none
  }

/-- Create a FusionReceipt from a SlabReceipt.
-/
def FusionReceipt.ofSlabReceipt [Inhabited Digest] (schemaId : String) (version : Nat)
    (slab : SlabReceipt α) : FusionReceipt α :=
  { schemaId := schemaId
    version := version
    statePrev := slab.statePrev
    stateNext := slab.stateNext
    spendAuth := slab.totalSpend
    defectDeclared := slab.totalDefect
    stepCount := slab.stepCount
    digest := none
    policyId := none
    canonId := none
    prevClaim := none
    nextClaim := none
  }

/-- Total spend across a trace. -/
def totalSpend [OfNat α 0] [HAdd α α α] : List (MicroReceipt α) → α
  | []      => 0
  | r :: rs => r.spendAuth + totalSpend rs

/-- Total defect across a trace. -/
def totalDefect [OfNat α 0] [HAdd α α α] : List (MicroReceipt α) → α
  | []      => 0
  | r :: rs => r.defectDeclared + totalDefect rs

/-- Final state after applying a trace. -/
def finalState : State6 α → List (MicroReceipt α) → State6 α
  | anchor, []      => anchor
  | _,      r :: rs => finalState r.stateNext rs

end CohFusion.Core
