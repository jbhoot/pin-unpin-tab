open Dom_api
open Ffext
open Rxjs

let toggle_pin (tab : Browser.tab) =
  Browser.Tabs.update tab.id { Browser.Tabs.pinned = not tab.pinned }

let _ =
  document
  |. Stream.from_event_DOMContentLoaded
  |. Stream.subscribe (fun _ ->
         let s_browser_action_clicked =
           Stream.from_event_pattern2
             (fun handler ->
               Browser.Browser_action.On_clicked.add_listener handler)
             (fun handler _signal ->
               Browser.Browser_action.On_clicked.remove_listener handler)
             (fun tab _on_click_data -> tab)
         in
         let s_runtime_message_received =
           Stream.from_event_pattern2
             (fun handler -> Browser.Runtime.On_message.add_listener handler)
             (fun handler _signal ->
               Browser.Runtime.On_message.remove_listener handler)
             (fun _msg sender -> sender)
         in
         let _ =
           Stream.subscribe s_browser_action_clicked (fun tab ->
               tab |. toggle_pin |. ignore)
         in
         let _ =
           Stream.subscribe s_runtime_message_received (fun sender ->
               sender.tab |. toggle_pin |. ignore)
         in
         ())
