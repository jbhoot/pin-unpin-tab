open Tea.Html2
module A = Tea.Html2.Attributes
module E = Tea.Html2.Events

type state =
  | Filling
  | Fixing

type input =
  { long_click_toggle : bool
  ; long_click_toggle_time : string
  }

type output =
  | Toggle_with_long_click of int
  | Dont_toggle_with_long_click

module Field = struct
  type t =
    | Long_click_toggle
    | Long_click_toggle_time

  let to_id t =
    match t with
    | Long_click_toggle -> "LongClickToggle"
    | Long_click_toggle_time -> "LongClickToggleTime"

  let to_error_description_id t = "Error-" ^ (t |> to_id)
  let to_normal_description_id t = "Desc-" ^ (t |> to_id)
  let to_attention_description_id t = "Attention-" ^ (t |> to_id)

  let parse_long_click_toggle input =
    match input with
    | true -> Ok true
    | false -> Ok false

  let parse_long_click_toggle_time input =
    match input |> Belt.Int.fromString with
    | Some v -> Ok v
    | None ->
      Error (Long_click_toggle_time, [ "Enter the time in milliseconds" ])
end

module Problem = struct
  type t = Invalid_input of Field.t * string

  let from_result parsed_input =
    match parsed_input with
    | Error (field, problems) ->
      Belt.List.map problems (fun p -> Invalid_input (field, p))
    | _ -> []

  let pick_problems_relevant_to_field field problems =
    Belt.List.keep problems (fun p ->
        match p with
        | Invalid_input (problem_field, _) -> problem_field = field)
end

let parse input =
  match
    ( input.long_click_toggle |> Field.parse_long_click_toggle
    , input.long_click_toggle_time |> Field.parse_long_click_toggle_time )
  with
  | Ok long_click_toggle, Ok long_click_toggle_time -> (
    match long_click_toggle with
    | true -> Ok (Toggle_with_long_click long_click_toggle_time)
    | false -> Ok Dont_toggle_with_long_click)
  | long_click_toggle_res, long_click_toggle_time_res ->
    Error
      (Belt.List.concat
         (long_click_toggle_res |> Problem.from_result)
         (long_click_toggle_time_res |> Problem.from_result))

type model =
  { state : state
  ; input : input
  ; problems : Problem.t list
  }

let init () =
  { state = Filling
  ; input = { long_click_toggle = false; long_click_toggle_time = "" }
  ; problems = []
  }

type msg =
  | Filled_toggle_long_click of bool
  | Filled_toggle_long_click_time of string

let field_has_errors field form =
  match form.state with
  | Filling -> false
  | Fixing -> (
    match form.problems |> Problem.pick_problems_relevant_to_field field with
    | [] -> false
    | _ -> true)

let view_field_errors form field =
  match form.state with
  | Filling -> noNode
  | Fixing -> (
    match form.problems |> Problem.pick_problems_relevant_to_field field with
    | [] -> noNode
    | relevant_problems ->
      ul
        [ field |> Field.to_error_description_id |> A.id ]
        (Belt.List.map relevant_problems (fun problem ->
             match problem with
             | Invalid_input (_, e) -> li [] [ e |> text ])))

let update m msg =
  match msg with
  | Filled_toggle_long_click v ->
          {
              state:  q
          }
  | Filled_toggle_long_click_time v -> (m, Tea.Cmd.none)

let view m = span [] []

let main =
  Tea.App.standardProgram
    { init = (fun () -> (init (), Tea.Cmd.none))
    ; subscriptions = (fun _ -> Tea.Sub.none)
    ; update
    ; view
    }

(* let view m = *)
(*     form [A.name "preferences"; A.novalidate true; E.onSubmit *)

(* open Js_of_ocaml *)
(* open Js_of_ocaml_lwt *)

(* let storage_local = Js.Unsafe.global##.browser##.storage##.local *)

(* let configure_long_click_toggle prefs = *)
(*   match *)
(* Dom_html.getElementById_coerce "longClickToggle" Dom_html.CoerceTo.input *)
(*   with *)
(*   | None -> () *)
(*   | Some checkbox -> *)
(*     let () = checkbox##.checked := prefs##.longClickToggle in *)

(*     let save_config checked = *)
(*       let upd = *)
(*         object%js *)
(*           val longClickToggle = checked *)
(*         end *)
(*       in *)
(*       ignore (storage_local##set upd) *)
(*     in *)

(*     let toggle_time_input checked = *)
(*       match *)
(*         Dom_html.getElementById_coerce "longClickToggleTime" *)
(*           Dom_html.CoerceTo.input *)
(*       with *)
(*       | None -> () *)
(* | Some textbox -> textbox##.disabled := Js.bool (not (Js.to_bool checked)) *)
(* in *)

(*     let (_ : unit Lwt.t) = *)
(*       let%lwt () = *)
(*         Lwt_js_events.changes checkbox (fun ev _ -> *)
(*             Js.Opt.iter *)
(*               (Dom_html.CoerceTo.input (Dom_html.eventTarget ev)) *)
(*               (fun input -> *)
(*                 save_config input##.checked; *)
(*                 toggle_time_input input##.checked); *)
(*             Lwt.return ()) *)
(*       in *)
(*       Lwt.return () *)
(*     in *)
(*     () *)

(* let configure_long_click_time_input prefs = *)
(*   match *)
(* Dom_html.getElementById_coerce "longClickToggleTime"
   Dom_html.CoerceTo.input *)
(*   with *)
(*   | None -> () *)
(*   | Some textbox -> *)
(*     let () = textbox##.value := prefs##.longClickToggleTime in *)
(*     let () = *)
(* textbox##.disabled := Js.bool (not (Js.to_bool prefs##.longClickToggle)) *)
(* in *)

(*     let (_ : unit Lwt.t) = *)
(*       let%lwt () = *)
(*         Lwt_js_events.changes textbox (fun ev _ -> *)
(*             Js.Opt.iter *)
(*               (Dom_html.CoerceTo.input (Dom_html.eventTarget ev)) *)
(*               (fun input -> *)
(*                 let upd = *)
(*                   object%js *)
(*                     val longClickToggleTime = input##.value *)
(*                   end *)
(*                 in *)
(*                 ignore (storage_local##set upd)); *)
(*             Lwt.return ()) *)
(*       in *)
(*       Lwt.return () *)
(*     in *)
(*     () *)

(* let (_ : unit Lwt.t) = *)
(*   let%lwt () = Lwt_js_events.domContentLoaded () in *)
(*   let (_ : unit Promise.t) = *)
(*     let open Promise.Syntax in *)
(*     let* curr_prefs = storage_local##get Common.prefs_query in *)
(*     let () = configure_long_click_toggle curr_prefs in *)
(*     let () = configure_long_click_time_input curr_prefs in *)
(*     Promise.resolve () *)
(*   in *)
(*   Lwt.return () *)
