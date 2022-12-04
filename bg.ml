open Dom_api
open Ffext

let toggle_pin (tab : Browser.tab) =
  Browser.Tabs.update tab.id { Browser.Tabs.pinned = not tab.pinned }

let init () =
  Ev.listen document
    (`DOMContentLoaded
      (fun _ ->
        Browser.Browser_action.On_clicked.add_listener (fun tab ->
            tab |> toggle_pin |> ignore);

        Browser.Runtime.On_message.add_listener_async (fun _ sender ->
            sender.tab |> toggle_pin)))
    None

let () = init ()
