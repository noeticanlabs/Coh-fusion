import CohFusion.Numeric.QFixed
open CohFusion.Numeric
def main : IO Unit := do
  let s := "0.05"
  match s.splitToList (· == ".") with
  | [whole, frac] => 
     let w := whole.toNat?.getD 0
     let f := frac.toNat?.getD 0
     IO.println s!"w: {w}, f: {f}"
  | _ => IO.println "fail"

