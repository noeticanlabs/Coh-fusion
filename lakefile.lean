import Lake
open Lake DSL

package «CohFusion» where
  moreLeanArgs := #["-DwarningAsError=true"]

lean_lib «CohFusion» where
  srcDir := "src"

@[default_target]
lean_exe «coh-fusion-control» where
  root := `Main
