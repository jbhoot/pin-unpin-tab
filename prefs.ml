let _ =
  let open Ff_webext_api in
  let open Promise.Syntax in
  let local_storage = browser |> Browser.storage |> Storage.local in
  let prefs = Lib.Query.make ~longClickToggle:true ~longClickToggleTime:600 in
  Storage.Local.set local_storage prefs >>| fun _ ->
  (* Local.get_some_with_defaults local query >>| fun res -> *)
  Storage.Local.get_all local_storage () >>| fun res ->
  Js_browser.Console.log Js_browser.console res

type 'msg Vdom.Cmd.t += Empty

let cmd_handler _ = function
  | Empty -> true
  | _ -> false

let () = Vdom_blit.register (Vdom_blit.cmd { f = cmd_handler })

type model = { stamp : float }

let update _ = function
  | `Click -> Vdom.return { stamp = Js_browser.Date.now () } ~c:[ Empty ]

let init = Vdom.return { stamp = 0. } ~c:[ Empty ]

let view model =
  let open Vdom in
  let t = Js_browser.Date.new_date model.stamp in
  div
    [ div
        [ text
            (Printf.sprintf "protocol: %S"
               (Js_browser.Location.protocol
                  (Js_browser.Window.location Js_browser.window)))
        ]
    ; div [ text (Printf.sprintf "Number of milliseconds: %f" model.stamp) ]
    ; div
        [ text
            (Printf.sprintf "ToDateString: %s"
               (Js_browser.Date.to_date_string t))
        ]
    ; div
        [ text
            (Printf.sprintf "ToLocaleString: %s"
               (Js_browser.Date.to_locale_string t))
        ]
    ; div
        [ input [] ~a:[ onclick (fun _ -> `Click); type_button; value "Update" ]
        ]
    ]

let app = Vdom.app ~init ~view ~update ()

let run () =
  Vdom_blit.run app |> Vdom_blit.dom
  |> Js_browser.Element.append_child
       (Js_browser.Document.body Js_browser.document)

let () = Js_browser.Window.set_onload Js_browser.window run