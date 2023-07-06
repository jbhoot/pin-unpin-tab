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

let set_abortable_timeout callback time long_click_abort_signal =
  let controller_to_cancel_abort_listener = AbortController.make () in
  let timer_id =
    set_timeout
      (fun () ->
        callback ();
        AbortController.abort controller_to_cancel_abort_listener None)
      time
  in
  Ev.on_abort long_click_abort_signal
    (fun _ -> clear_timeout timer_id)
    ~opts:
      (Some
         { signal =
             Some (AbortController.signal controller_to_cancel_abort_listener)
         ; once = Some true
         ; capture = None
         ; passive = None
         })

let init (prefs : Common.Storage_args.t) =
  match prefs.longClickToggle with
  | true ->
    let abort_controller = AbortController.make () in
    let opts =
      { Ev.signal = Some (AbortController.signal abort_controller)
      ; once = Some false
      ; capture = None
      ; passive = None
      }
    in
    Ev.listen_with_opts document
      (`mousedown
        (fun ev ->
          match
            ev |> clicked_only_left_button
            && ev |> Mouse_ev.target |> clicked_on_passive_ele
          with
          | true ->
            let abort_controller = AbortController.make () in
            let opts =
              { Ev.signal = Some (abort_controller |> AbortController.signal)
              ; once = Some true
              ; capture = None
              ; passive = None
              }
            in
            let abort_long_click _ =
              AbortController.abort abort_controller None
            in
            let trigger_long_click () =
              Ffext.Browser.Runtime.send_message_internally "toggle" |> ignore
            in
            Ev.listen_with_opts document (`mouseup abort_long_click) opts;
            Ev.listen_with_opts document (`mousemove abort_long_click) opts;
            Ev.listen_with_opts document (`scroll abort_long_click) opts;
            Ev.listen_with_opts (ev |> Mouse_ev.target)
              (`scroll abort_long_click) opts;
            set_abortable_timeout trigger_long_click prefs.longClickToggleTime
              (AbortController.signal abort_controller)
          | false -> ()))
      opts;
    Some abort_controller
  | false -> None

let () =
  let abortController = ref None in
  let boot () =
    let () =
      match !abortController with
      | Some ac -> AbortController.abort ac None
      | None -> ()
    in
    Common.Storage_args.make_default ()
    |. Common.Storage.Local.get
    |. Promise.Js.toResult
    |. Promise.get (fun res ->
           match res with
           | Ok prefs -> abortController := init prefs
           | Error _ ->
             abortController := init (Common.Storage_args.make_default ()))
  in
  Common.Storage.On_changed.add_listener (fun _ _ -> boot ());
  boot ()

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

let s_mouse_up =
  document
  |. Stream.from_event_mouseup
  |. Stream.pipe1 (Op.map (fun _v _i -> ()))

let s_mouse_move =
  document
  |. Stream.from_event_mousemove
  |. Stream.pipe1 (Op.map (fun _v _i -> ()))

let s_abort_trigger = Op.merge2 s_mouse_up s_mouse_move

let s_long_click_trigger =
  Stream.timer (Cell.get_value c_long_click_toggle_time)
  |. Stream.pipe2
       (Op.tap (fun _v -> Js.Console.log "Timeout triggered"))
       (Op.take_until s_abort_trigger)

let s_mousedown =
  document
  |. Stream.from_event_mousedown
  |. Stream.pipe2
       (Op.merge_map (fun _v _i -> s_long_click_trigger))
       (Op.take_until s_long_click_false)

let s_result =
  s_long_click_true |. Stream.pipe1 (Op.merge_map (fun _v _i -> s_mousedown))

let _ = Stream.subscribe s_result (fun v -> Js.Console.log2 "Sub ev" v)
