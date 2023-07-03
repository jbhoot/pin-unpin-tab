open Common
open Dom_api
open Js_api
open Rxjs

let is_long_click_toggle_time_input_valid v =
  (* TODO: Switch to Number.make_int + isNaN check? *)
  match Belt.Int.fromString v with
  | Some i -> i >= 800
  | None -> false

let s_initial_config =
  Storage_args.make_default () |. Storage.Local.get |. Stream.from_promise

let s_long_click_toggle_init =
  (* TODO: Inspect why v's type isn't being inferred here. *)
  (* Probably because of the similarity in Storage_args.t and
     Storage_args.change types *)
  s_initial_config
  |. Stream.pipe1 (Op.map (fun (v : Storage_args.t) _ -> v.longClickToggle))

let _ =
  Stream.subscribe s_long_click_toggle_init (fun v ->
      document
      |. Document.get_element_by_id "longClickToggle"
      |. InputElement.from_element
      |. InputElement.set_checked v)

let s_long_click_toggle_input =
  document
  |. Document.get_element_by_id "longClickToggle"
  |. InputElement.from_element
  |. Stream.from_event_change `change
  |. Stream.pipe1
       (Op.map (fun ev _ ->
            ev |. Generic_ev.current_target |. InputElement.get_checked))

let s_long_click_toggle_change =
  Op.merge2 s_long_click_toggle_init s_long_click_toggle_input

let _ =
  Stream.subscribe s_long_click_toggle_change (fun v ->
      document
      |. Document.get_element_by_id "longClickToggleTime"
      |. InputElement.from_element
      |. InputElement.set_disabled (not v))

let s_long_click_toggle_time_init =
  s_initial_config
  |. Stream.pipe1
       (Op.map (fun (v : Storage_args.t) _ ->
            Js.Int.toString v.longClickToggleTime))

let _ =
  Stream.subscribe s_long_click_toggle_time_init (fun v ->
      document
      |. Document.get_element_by_id "longClickToggleTime"
      |. InputElement.from_element
      |. InputElement.set_value v)

let s_long_click_toggle_time_input =
  document
  |. Document.get_element_by_id "longClickToggleTime"
  |. InputElement.from_element
  |. Stream.from_event_input `input
  |. Stream.pipe1
       (Op.map (fun ev _ ->
            ev |. Generic_ev.current_target |. InputElement.get_value))

let s_long_click_toggle_time_change =
  Op.merge2 s_long_click_toggle_time_init s_long_click_toggle_time_input

let s_is_long_click_toggle_time_valid =
  s_long_click_toggle_time_change
  |. Stream.pipe1 (Op.map (fun v _ -> is_long_click_toggle_time_input_valid v))

let _ =
  Stream.subscribe s_is_long_click_toggle_time_valid (fun v ->
      document
      |. Document.get_element_by_id "longClickToggleTime"
      |. Element.set_attribute "aria-invalid"
           (match v with
           | true -> "false"
           | false -> "true"))

let s_long_click_toggle_time_parsed =
  s_long_click_toggle_time_change
  |. Stream.pipe2
       (Op.filter (fun v _ -> is_long_click_toggle_time_input_valid v))
       (Op.map (fun v _ -> Number.make_int v))

let s_config =
  Op.combineLatest2 s_long_click_toggle_change s_long_click_toggle_time_parsed
    (fun tgl time ->
      let v : Storage_args.t =
        { longClickToggle = tgl; longClickToggleTime = time }
      in
      v)

let _ = s_config |. Stream.subscribe (fun v -> Storage.Local.set v |. ignore)
