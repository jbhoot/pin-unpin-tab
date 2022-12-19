open Tea.Html2
module A = Tea.Html2.Attributes
module E = Tea.Html2.Events

module F_args = struct
  let id = "PreferenceForm"

  type field =
    | Long_click_toggle
    | Long_click_toggle_time

  let field_id field =
    match field with
    | Long_click_toggle -> "Long_click_toggle"
    | Long_click_toggle_time -> "Long_click_toggle_time"

  type input =
    { long_click_toggle : bool
    ; long_click_toggle_time : string
    }

  type output =
    | Toggle_with_long_click of int
    | Dont_toggle_with_long_click

  type problem =
    | Field_error of field * string
    | Form_error of string

  let parse input =
    let parse_long_click_toggle value =
      match value with
      | true -> Ok true
      | false -> Ok false
    in
    let parse_long_click_toggle_time value =
      match value |> Belt.Int.fromString with
      | Some v -> Ok v
      | None ->
        Error
          [ Field_error
              (Long_click_toggle_time, "Enter the time in milliseconds")
          ]
    in
    match
      ( input.long_click_toggle |> parse_long_click_toggle
      , input.long_click_toggle_time |> parse_long_click_toggle_time )
    with
    | Ok long_click_toggle, Ok long_click_toggle_time -> (
      match long_click_toggle with
      | true -> Ok (Toggle_with_long_click long_click_toggle_time)
      | false -> Ok Dont_toggle_with_long_click)
    | long_click_toggle_res, long_click_toggle_time_res ->
      Error
        ((long_click_toggle_res |> Form.extract_problems)
        @ (long_click_toggle_time_res |> Form.extract_problems))

  let init_input init =
    match init with
    | Some init -> init
    | None ->
      { long_click_toggle = Common.prefs_query.longClickToggle
      ; long_click_toggle_time =
          Common.prefs_query.longClickToggleTime |> string_of_int
      }
end

module F = Form.Make (F_args)

type model = F.t

type msg =
  | Filled_long_click_toggle of bool
  | Filled_long_click_toggle_time of string

let view (m : model) =
  form
    [ A.name F.id; A.novalidate true ]
    [ h1 [] [ text "Preferences" ]
    ; div []
        [ input'
            [ A.type' "checkbox"
            ; A.id (F.Field.to_id Long_click_toggle)
            ; A.name (F.Field.to_id Long_click_toggle)
            ; A.value (F.Field.to_id Long_click_toggle)
            ; A.checked m.input.long_click_toggle
            ; E.onCheck (fun v -> Filled_long_click_toggle v)
            ]
            []
        ; label
            [ A.for' (F.Field.to_id Long_click_toggle) ]
            [ text "Pin / unpin on holding left click" ]
        ]
    ; div []
        [ input'
            [ A.type' "text"
            ; A.id (F.Field.to_id Long_click_toggle_time)
            ; A.name (F.Field.to_id Long_click_toggle_time)
            ; A.value m.input.long_click_toggle_time
            ; E.onChange (fun v -> Filled_long_click_toggle_time v)
            ]
            []
        ; label
            [ A.for' (F.Field.to_id Long_click_toggle_time) ]
            [ text "Hold left click for milliseconds" ]
        ]
    ]

let update m msg =
  match msg with
  | Filled_long_click_toggle v ->
    let input = { m.F.input with long_click_toggle = v } in
    m |> F.update_form_with_input ~input
  | Filled_long_click_toggle_time v ->
    let input = { m.input with long_click_toggle_time = v } in
    m |> F.update_form_with_input ~input

let init = 
    (F.init (), Tea.Cmd.none)

let main =
  Tea.App.standardProgram
    { init = init ();
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
