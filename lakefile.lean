import Lake
open Lake DSL

package «CohFusion» where
  -- Strict compiler flags for deterministic verification
  moreLeanArgs := #["-DwarningAsError=true", "-Dpp.all=true"]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.10.0"

@[default_target]
lean_lib «CohFusion» where
  srcDir := "src"
