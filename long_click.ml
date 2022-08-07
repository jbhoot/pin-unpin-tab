open Js_of_ocaml
open Js_of_ocaml_lwt

let browser = Js.Unsafe.global##.browser
let storage_all = Js.Unsafe.global##.browser##.storage
let storage_local = Js.Unsafe.global##.browser##.storage##.local

let clicked_only_left_button ev =
  Dom_html.buttonPressed ev = Dom_html.Left_button
  && ev##.shiftKey = Js._false
  && ev##.ctrlKey = Js._false
  && ev##.altKey = Js._false

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
         ele##closest (selector |> Js.string) |> Js.Opt.test |> not)

type wait =
  | WaitUntilTimeout
  | WaitUntilMouseUp
  | WaitUntilMouseMove
  | WaitUntilElementScroll

let wait_until_timeout time =
  let%lwt () = Lwt_js.sleep time in
  Lwt.return WaitUntilTimeout

let wait_until_mouse_up target =
  let%lwt _ = Lwt_js_events.mouseup target in
  Lwt.return WaitUntilMouseUp

let wait_until_mouse_move target =
  let%lwt _ = Lwt_js_events.mousemove target in
  Lwt.return WaitUntilMouseMove

let wait_until_element_scroll target =
  let%lwt _ = Lwt_js_events.scroll target in
  Lwt.return WaitUntilElementScroll

let _ =
  let%lwt () = Lwt_js_events.domContentLoaded () in
  let listener_handle = ref (Lwt.return ()) in

  let init config =
    match config##.longClickToggle with
    | true ->
      let%lwt () =
        Lwt_js_events.mousedowns Dom_html.window (fun ev _ ->
            match
              ev |> clicked_only_left_button
              && ev |> Dom_html.eventTarget |> clicked_on_passive_ele
            with
            | true -> (
              let%lwt waited =
                Lwt.pick
                  [ config##.longClickToggleTime /. 1000. |> wait_until_timeout
                  ; ev |> Dom_html.eventTarget |> wait_until_mouse_up
                  ; ev |> Dom_html.eventTarget |> wait_until_mouse_move
                  ; ev |> Dom_html.eventTarget |> wait_until_element_scroll
                  ; Dom_html.window |> wait_until_element_scroll
                  ]
              in
              match waited with
              | WaitUntilMouseUp
              | WaitUntilMouseMove
              | WaitUntilElementScroll ->
                Lwt.return ()
              | WaitUntilTimeout ->
                let _ = browser##.runtime##sendMessage (Js.string "toggle") in
                Lwt.return ())
            | false -> Lwt.return ())
      in
      Lwt.return ()
    | false -> Lwt.return ()
  in

  let restart () =
    let (_ : unit Promise.t) =
      let open Promise.Syntax in
      let* config = storage_local##get Common.prefs_query in
      Lwt.cancel !listener_handle;
      listener_handle := init config;
      Promise.resolve ()
    in
    ()
  in

  let () = storage_all##.onChanged##addListener (fun _changes -> restart ()) in

  Lwt.return (restart ())
