-- Coh-Fusion Library Root
-- Re-exports all public modules from the new structured tree

import CohFusion.Core.State
import CohFusion.Core.Receipt
import CohFusion.Core.Decision
import CohFusion.Core.CohObject
import CohFusion.Core.Obligations

import CohFusion.Numeric.QFixed
import CohFusion.Numeric.Interval
import CohFusion.Numeric.Policy
import CohFusion.Numeric.Serialize
import CohFusion.Numeric.BoundsAxioms

import CohFusion.Crypto.Digest
import CohFusion.Crypto.DigestStub
import CohFusion.Crypto.Serialize
import CohFusion.Crypto.Ledger

-- Future layers (available for import):
-- import CohFusion.Geometry.VDE
-- import CohFusion.Geometry.Tearing
-- import CohFusion.Geometry.Composition
-- import CohFusion.Control.Burn
-- import CohFusion.Continuum.Observables
-- import CohFusion.Continuum.LiftedSet
-- import CohFusion.Continuum.OplaxProjection
-- import CohFusion.Runtime.HashBoundedReceipt
-- import CohFusion.Runtime.VerifierSemantics
-- import CohFusion.Runtime.Bridge
