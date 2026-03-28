import Lean.Data.Json
def main : IO Unit := 
  match Lean.JsonNumber.fromString "0.05" with
  | some jn => IO.println jn.toFloat
  | none => IO.println "fail"

