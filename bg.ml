open Js_of_ocaml
open Js_of_ocaml_lwt
  
let calc_new_pinned_state is_pinned =
  object%js
    val pinned = Js.bool (not (Js.to_bool is_pinned))
  end

let pin_unpin tab =
  let new_state = calc_new_pinned_state tab##.pinned in
  Js.Unsafe.global##.browser##.tabs##update tab##.id new_state

let _ =
  let%lwt _ = Lwt_js_events.domContentLoaded () in
    let browser = Js.Unsafe.global##.browser in
    let () = browser##.browserAction##.onClicked##addListener pin_unpin in 
    (* onMessage handler does not verify that the incoming message is 'toggle' *)
    (* because 'toggle' is the only message passed around in this add-on. *)
    let () = browser##.runtime##.onMessage##addListener (fun msg sender -> pin_unpin sender##.tab) in
    Lwt.return ()