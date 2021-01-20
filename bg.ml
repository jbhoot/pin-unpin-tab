open Js_of_ocaml
open Js_of_ocaml_lwt

let browser = Js.Unsafe.global##.browser

let calc_new_pinned_state is_pinned =
  object%js
    val pinned = Js.bool (not (Js.to_bool is_pinned))
  end

let pin_unpin tab =
  browser##.tabs##update
    tab##.id
    (calc_new_pinned_state tab##.pinned)

let (_ : unit Lwt.t) =
  let%lwt () = Lwt_js_events.domContentLoaded () in

  let () = browser##.browserAction##.onClicked##addListener pin_unpin in 
  let () = browser##.runtime##.onMessage##addListener
    (fun _msg sender -> 
      (* onMessage handler does not verify that the incoming message is 'toggle' *)
      (* because 'toggle' is the only message passed around in this add-on. *)  
      pin_unpin sender##.tab) 
  in

  Lwt.return ()