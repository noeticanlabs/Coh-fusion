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
-- import CohFusion.Crypto.DigestStub  -- REMOVED: Stub leaks into production; keep isolated for dev only
import CohFusion.Crypto.Serialize
import CohFusion.Crypto.Ledger

import CohFusion.Geometry.VDECore
import CohFusion.Geometry.VDERuntime
import CohFusion.Geometry.TearingCore
import CohFusion.Geometry.TearingRuntime
import CohFusion.Geometry.Composition
import CohFusion.Product.HardwareCertificate
import CohFusion.Product.CommercialWedge
import CohFusion.Control.BurnContract
import CohFusion.Control.BurnPolicyDemo

import CohFusion.Control.VDE_Abstract
import CohFusion.Control.VDE_Quadratic
import CohFusion.Control.Tearing_Quadratic
import CohFusion.Control.Composition

import CohFusion.Continuum.Observables
import CohFusion.Continuum.LiftedSet
import CohFusion.Continuum.OplaxProjection

import CohFusion.Runtime.HashBoundedReceipt
import CohFusion.Runtime.VerifierSemantics
import CohFusion.Runtime.Bridge

import CohFusion.Control.Theorems.C4B_DissipativeDescent
import CohFusion.Control.Theorems.C4B_VDE
import CohFusion.Control.Theorems.C4B_Tearing
import CohFusion.Geometry.Theorems.C2C_Transversality
