type 'msg Vdom.Cmd.t +=
  | GetStoredState of
      { default_app_state : Lib.app_state
      ; on_success : Lib.app_state -> 'msg
      }

let run_hydrate default_app_state on_done =
  let open Ff_webext_api in
  let open Promise.Syntax in
  let local_storage = browser |> Browser.storage |> Storage.local in
  let query =
    Lib.(
      Query.make ~long_click_toggle:default_app_state.long_click_toggle
        ~long_click_toggle_time:default_app_state.long_click_toggle_time)
  in
  let _ =
    query |> Storage.Local.get_some_with_defaults local_storage >>| fun res ->
    res |> Lib.cast_to_app_state |> on_done
  in
  ()

let cmd_handler ctx msg =
  match msg with
  | GetStoredState { default_app_state; on_success } ->
    run_hydrate default_app_state (fun state ->
        Vdom_blit.Cmd.send_msg ctx (on_success state));
    true
  | _ -> false

let () = { f = cmd_handler } |> Vdom_blit.cmd |> Vdom_blit.register

let update _ msg =
  match msg with
  | `GotStoredState stored_state -> Vdom.return stored_state

let default_app_state =
  Lib.{ long_click_toggle = true; long_click_toggle_time = 600 }

let init =
  Vdom.return default_app_state
    ~c:
      [ GetStoredState
          { default_app_state
          ; on_success = (fun app_state -> `GotStoredState app_state)
          }
      ]

let view model =
  let open Vdom in
  let open Vdom2 in
  let open Lib in
  Form.ele
    [ div
        [ text
            (Printf.sprintf "Long click toggle time: %d"
               model.long_click_toggle_time)
        ; Label.ele "" [ Input.Radio.ele "On"; text "Radio input" ]
        ]
    ; div
        [ text (Printf.sprintf "Long click toggle?: %B" model.long_click_toggle)
        ]
    ]

let app = Vdom.app ~init ~view ~update ()

let run () =
  Vdom_blit.run app |> Vdom_blit.dom
  |> Js_browser.Element.append_child
       (Js_browser.Document.body Js_browser.document)

let () = Js_browser.Window.set_onload Js_browser.window run