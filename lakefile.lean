import Lake
open Lake DSL

package «CohFusion» where
  moreLeanArgs := #["-DwarningAsError=true"]

lean_lib «CohFusion» where
  srcDir := "src"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.25.0"

@[default_target]
lean_exe «coh-fusion-control» where
  root := `Main
