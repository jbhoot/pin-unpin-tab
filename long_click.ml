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
  Ev.listen abort_signal
    (`abort_abortsignal (fun _ -> timer_id |> clear_timeout))
    (Some
       { signal = Some (signal_aborter |> AbortController.signal)
       ; once = Some true
       ; capture = None
       ; passive = None
       })

let clicked_only_left_button ev =
  ev |> Mouse_ev.button = 1
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

let () =
  Ev.listen document
    (`DOMContentLoaded
      (fun _ ->
        let abortController = ref None in
        let init prefs =
          match prefs.Common.longClickToggle with
          | true ->
            let abort_controller = AbortController.make () in
            let opts =
              Some
                { Ev.signal = Some (abort_controller |> AbortController.signal)
                ; once = Some true
                ; capture = None
                ; passive = None
                }
            in
            Ev.listen document
              (`mousedown
                (fun ev ->
                  match
                    ev |> clicked_only_left_button
                    && ev |> Mouse_ev.target |> clicked_on_passive_ele
                  with
                  | true ->
                    let abort_controller = AbortController.make () in
                    let opts =
                      Some
                        { Ev.signal =
                            Some (abort_controller |> AbortController.signal)
                        ; once = Some true
                        ; capture = None
                        ; passive = None
                        }
                    in
                    let abort_long_click _ =
                      AbortController.abort abort_controller None
                    in
                    let trigger_long_click () =
                      Ffext.Browser.Runtime.send_message_internally "toggle"
                      |> ignore
                    in
                    Ev.listen document (`mouseup abort_long_click) opts;
                    Ev.listen document (`mousemove abort_long_click) opts;
                    Ev.listen document (`scroll abort_long_click) opts;
                    Ev.listen (ev |> Mouse_ev.target) (`scroll abort_long_click)
                      opts;
                    set_abortable_timeout trigger_long_click 1000.
                      (abort_controller |> AbortController.signal)
                  | false -> ()))
              opts;
            Some abort_controller
          | false -> None
        in
        let restart () =
          match !abortController with
          | Some ac -> AbortController.abort ac None
          | None ->
            ();
            Promise.get (Ffext.Browser.Storage.Local.get Common.prefs_query)
              (fun prefs -> abortController := init prefs)
        in
        Ffext.Browser.Storage.On_changed.add_listener (fun _ _ -> restart ());
        restart ()))
    None

(* type wait = *)
(*   | WaitUntilTimeout *)
(*   | WaitUntilMouseUp *)
(*   | WaitUntilMouseMove *)
(*   | WaitUntilElementScroll *)

(* let wait_until_timeout time = *)
(*   let%lwt () = Lwt_js.sleep time in *)
(*   Lwt.return WaitUntilTimeout *)

(* let wait_until_mouse_up target = *)
(*   let%lwt _ = Lwt_js_events.mouseup target in *)
(*   Lwt.return WaitUntilMouseUp *)

(* let wait_until_mouse_move target = *)
(*   let%lwt _ = Lwt_js_events.mousemove target in *)
(*   Lwt.return WaitUntilMouseMove *)

(* let wait_until_element_scroll target = *)
(*   let%lwt _ = Lwt_js_events.scroll target in *)
(*   Lwt.return WaitUntilElementScroll *)

(* let _ = *)
(*   let%lwt () = Lwt_js_events.domContentLoaded () in *)
(*   let listener_handle = ref (Lwt.return ()) in *)

(*   let init config = *)
(*     match config##.longClickToggle with *)
(*     | true -> *)
(*       let%lwt () = *)
(*         Lwt_js_events.mousedowns Dom_html.window (fun ev _ -> *)
(*             match *)
(*               ev |> clicked_only_left_button *)
(*               && ev |> Dom_html.eventTarget |> clicked_on_passive_ele *)
(*             with *)
(*             | true -> ( *)
(*               let%lwt waited = *)
(*                 Lwt.pick *)
(* [ config##.longClickToggleTime /. 1000. |> wait_until_timeout *)
(*                   ; ev |> Dom_html.eventTarget |> wait_until_mouse_up *)
(*                   ; ev |> Dom_html.eventTarget |> wait_until_mouse_move *)
(*                   ; ev |> Dom_html.eventTarget |> wait_until_element_scroll *)
(*                   ; Dom_html.window |> wait_until_element_scroll *)
(*                   ] *)
(*               in *)
(*               match waited with *)
(*               | WaitUntilMouseUp *)
(*               | WaitUntilMouseMove *)
(*               | WaitUntilElementScroll -> *)
(*                 Lwt.return () *)
(*               | WaitUntilTimeout -> *)
(* let _ = browser##.runtime##sendMessage (Js.string "toggle") in *)
(*                 Lwt.return ()) *)
(*             | false -> Lwt.return ()) *)
(*       in *)
(*       Lwt.return () *)
(*     | false -> Lwt.return () *)
(*   in *)

(*   let restart () = *)
(*     let (_ : unit Promise.t) = *)
(*       let open Promise.Syntax in *)
(*       let* config = storage_local##get Common.prefs_query in *)
(*       Lwt.cancel !listener_handle; *)
(*       listener_handle := init config; *)
(*       Promise.resolve () *)
(*     in *)
(*     () *)
(*   in *)

(* let () = storage_all##.onChanged##addListener (fun _changes -> restart ())
   in *)

(* Lwt.return (restart ()) *)
