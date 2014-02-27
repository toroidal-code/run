open Core.Std
open Yojson

module StringMap = Map.Make(String)

let to_map in_json =
  let map = StringMap.empty in
  let json_assoc = Yojson.Basic.Util.to_assoc in_json in
  List.iter ~f:(fun (str, js) -> 
      (StringMap.add 
         ~key:str 
         ~data:(Yojson.Basic.Util.to_string js) 
         map);
      ());
  map
  


let command =
  Command.basic
    ~summary:"Run some arbitrary script file"
    ~readme:(fun () -> "More detailed information")
    Command.Spec.(empty +> anon ("filename" %: string))
    (fun filename () -> print_string filename)

let () =
  (* Read the JSON file *)
  let file_map =  Yojson.Basic.from_file "commands.json" |> to_map in
  Command.run ~version:"1.0" ~build_info:"RWO" command



