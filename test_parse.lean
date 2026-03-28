import Lean.Data.Json
open Lean
def main : IO Unit := do
  match Json.parse "0.05" with
  | Except.ok (Json.num n) => IO.println s!"val: {n.toFloat}"
  | _ => IO.println "fail"

