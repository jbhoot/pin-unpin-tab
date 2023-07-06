open Dom_api
open Rxjs
open Common

let clicked_only_left_button ev =
  ev |> Mouse_ev.button == 0
  && ev |> Mouse_ev.shift_key |> not
  && ev |> Mouse_ev.alt_key |> not

let clicked_on_passive_ele ele =
  let selectors =
    [ "input"
    ; "button"
    ; "a"
    ; "textarea"
    ; "select"
    ; "datalist"
    ; "option"
    ; "summary"
    ; "video"
    ; "audio"
    ; "area"
    ; "map"
    ; "[role='button]"
    ; "[role='checkbox]"
    ; "[role='textbox']"
    ; "[role='listbox']"
    ; "[role='option']"
    ; "[role='combobox']"
    ; "[role='tab']"
    ; "[role='switch']"
    ]
  in
  selectors
  |> List.for_all (fun selector ->
         match Dom_api.Element.closest ele selector with
         | Some _ -> false
         | None -> true)

let defaults = Storage_args.make_default ()
let s_initial_config = defaults |. Storage.Local.get |. Stream.from_promise

let s_config_changed =
  Stream.from_event_pattern2
    (fun handler -> Common.Storage.On_changed.add_listener handler)
    (fun handler _signal -> Common.Storage.On_changed.remove_listener handler)
    (fun _changes _area_name -> ())
  |. Stream.pipe1
       (Op.merge_map (fun _unit _i ->
            defaults |. Storage.Local.get |. Stream.from_promise))

let s_config = Op.merge2 s_initial_config s_config_changed

let s_long_click_toggle =
  (* TODO: Inspect why v's type isn't being inferred here. *)
  (* Probably because of the similarity in Storage_args.t and
     Storage_args.change types *)
  s_config
  |. Stream.pipe1 (Op.map (fun (v : Storage_args.t) _ -> v.longClickToggle))

let s_long_click_true =
  s_long_click_toggle |. Stream.pipe1 (Op.filter (fun v _i -> v = true))

let s_long_click_false =
  s_long_click_toggle |. Stream.pipe1 (Op.filter (fun v _i -> v = false))

let c_long_click_toggle_time =
  s_config
  |. Stream.pipe1 (Op.map (fun (v : Storage_args.t) _ -> v.longClickToggleTime))
  |. Op.hold defaults.longClickToggleTime

let make_long_click_trigger mousedown_ev =
  let opts : Ev.opts option =
    Some { once = Some true; capture = None; passive = None; signal = None }
  in
  let s_mouse_up =
    document
    |. Stream.from_event_mouseup ~opts
    |. Stream.pipe1 (Op.map (fun _v _i -> ()))
  in
  let s_mouse_move =
    document
    |. Stream.from_event_mousemove ~opts
    |. Stream.pipe1 (Op.map (fun _v _i -> ()))
  in
  let s_document_scroll =
    document
    |. Stream.from_event_scroll_d ~opts
    |. Stream.pipe1 (Op.map (fun _v _i -> ()))
  in
  let s_element_scroll =
    mousedown_ev
    |. Mouse_ev.target
    |. Stream.from_event_scroll_e ~opts
    |. Stream.pipe1 (Op.map (fun _v _i -> ()))
  in
  let s_abort_trigger =
    Op.merge4 s_mouse_up s_mouse_move s_document_scroll s_element_scroll
  in
  Stream.timer (Cell.get_value c_long_click_toggle_time)
  |. Stream.pipe2
       (Op.tap (fun _v -> Js.Console.log "Timeout triggered"))
       (Op.take_until s_abort_trigger)

let s_result =
  s_long_click_true
  |. Stream.pipe1
       (* (Op.tap (fun _v -> Js.Console.log "Go yo")) *)
       (Op.merge_map (fun _v _i ->
            document
            |. Stream.from_event_mousedown ~opts:None
            |. Stream.pipe4
                 (Op.filter (fun ev _i -> clicked_only_left_button ev))
                 (Op.filter (fun ev _i ->
                      clicked_on_passive_ele (Mouse_ev.target ev)))
                 (Op.merge_map (fun ev _i -> make_long_click_trigger ev))
                 (Op.take_until s_long_click_false)))

let _ =
  Stream.subscribe s_result (fun _v ->
      Ffext.Browser.Runtime.send_message_internally "toggle" |> ignore)
