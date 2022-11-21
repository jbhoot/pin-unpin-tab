open Dom_api
open Ffext

let calc_new_pinned_state is_pinned = { Browser.Tabs.pinned = not is_pinned }

let pin_unpin (tab : Browser.tab) =
  Browser.Tabs.update tab.id (calc_new_pinned_state tab.pinned)

let init () =
  window
  |. Window.add_event_listener "DOMContentLoaded" (fun _ ->
         Browser.Browser_action.On_clicked.add_listener (fun tab ->
             tab |> pin_unpin |> ignore);

         Browser.Runtime.On_message.add_listener_async (fun _ sender ->
             pin_unpin sender.tab))

let () = init ()
