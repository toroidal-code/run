open Core.Std
open Yojson

module StringMap = Map.Make(String)

let to_map in_json =
  let json_assoc = Yojson.Basic.Util.to_assoc in_json in
  let rec to_map_helper in_json_list acc_map = 
    (match in_json_list with
     | [ ] -> acc_map
     | (str, js)::tl -> 
       let add_map = (StringMap.add ~key:str ~data:(Yojson.Basic.Util.to_string js) acc_map) in 
       to_map_helper tl add_map) 
  in
  to_map_helper json_assoc (StringMap.empty)
  
let print_map map =
  StringMap.iter map ~f:(fun ~key ~data ->
      printf "%s => %s\n" key data)

let command =
  Command.basic
    ~summary:"Run some arbitrary script file"
    ~readme:(fun () -> "More detailed information")
    Command.Spec.(empty +> anon ("filename" %: string))
    (fun filename () -> print_string filename)


let command_map =   
  let home = match Sys.getenv "HOME" with
    | Some(str) -> str
    | None -> assert false
  in
  (* Read the JSON file *)
  let file_map = try Yojson.Basic.from_file "commands.json" |> to_map with
    | Sys_error(str) -> 
      printf "Error: %s" str; 
      exit 1
  in
  let user_map = try Some(Yojson.Basic.from_file (home ^ "/.run") |> to_map) with
    | Sys_error(_) -> 
      print_string "Warning: We couldn't find a user-defined run definitions file\n";
      None
  in
  match user_map with 
    | None -> file_map
    | Some(some_user_map) -> StringMap.merge some_user_map file_map ~f:(fun ~key value ->
        match value with
        | `Both (user, _)
        | `Left user -> Some(user)
        | `Right sys -> Some(sys))

let () =
  print_map command_map;
  Command.run ~version:"1.0" ~build_info:"RWO" command
