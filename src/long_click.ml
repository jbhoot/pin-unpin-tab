open Dom_api

let set_abortable_timeout callback time abort_signal =
  let signal_aborter = AbortController.make () in
  let timer_id =
    set_timeout
      (fun () ->
        AbortController.abort signal_aborter None;
        callback ())
      time
  in
  Ev.listen_with_opts abort_signal
    (`abort_abortsignal (fun _ -> timer_id |> clear_timeout))
    { signal = Some (signal_aborter |> AbortController.signal)
    ; once = Some true
    ; capture = None
    ; passive = None
    }

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
