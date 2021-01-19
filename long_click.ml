open Js_of_ocaml
open Js_of_ocaml_lwt

let clicked_on_document_scrollbar : Dom_html.mouseEvent Js.t -> bool = fun ev ->
  let doc_ele = Dom_html.document##.documentElement in
  ev##.clientX >= doc_ele##.offsetWidth ||
  ev##.clientY >= doc_ele##.offsetHeight

let clicked_on_element_scrollbar : Dom_html.mouseEvent Js.t -> bool = fun ev ->
  let ev_target = Dom_html.eventTarget ev in
  let bounding_rect = ev_target##getBoundingClientRect in
  (float_of_int ev##.clientX) > bounding_rect##.left +. (float_of_int ev_target##.clientWidth) ||
  (float_of_int ev##.clientY) > bounding_rect##.top +. (float_of_int ev_target##.clientHeight)

let clicked_only_left_button : Dom_html.mouseEvent Js.t -> bool = fun ev ->
    (* ev##.button = 0 && *)
    (* ev##.buttons = 1 && *)
    Dom_html.buttonPressed ev = Dom_html.Left_button &&
    ev##.shiftKey = Js._false &&
    ev##.ctrlKey = Js._false &&
    ev##.altKey = Js._false  

let is_valid_click : Dom_html.mouseEvent Js.t -> bool = fun ev ->
  clicked_only_left_button ev &&
  not (clicked_on_document_scrollbar ev) &&
  not (clicked_on_element_scrollbar ev)

let request_toggle after =
  let () = Firebug.console##log after in
  Dom_html.setTimeout
    (fun () ->
      let () = Firebug.console##log (Js.string "triggered")  in
      Js.Unsafe.global##.browser##.runtime##sendMessage (Js.string "toggle"))
    after

let cancel_toggle request_id =
  let%lwt () = Lwt.pick [
    (let%lwt _ = Lwt_js_events.mouseup Dom_html.window in
      Lwt.return (Dom_html.clearTimeout request_id));
    (let%lwt _ = Lwt_js_events.mousemove Dom_html.window in
      Lwt.return (Dom_html.clearTimeout request_id))
  ]
  in Lwt.return ()

let trigger_long_click_mechanism ev _ =
  if is_valid_click ev then
    let _ = let open Promise.Syntax in
    let* prefs = Js.Unsafe.global##.browser##.storage##.local##get Common.prefs_query in
      let request_id = request_toggle prefs##.longClickToggleTime in
      let _ = cancel_toggle request_id in
      Promise.resolve ()
    in
    Lwt.return ()
  else
    Lwt.return ()

let _ = 
  let promise =
    Lwt.bind
      (Lwt_js_events.mousedowns Dom_html.window trigger_long_click_mechanism)
      (fun () -> Lwt.return ())
    (* let promise =
      let%lwt () = Lwt_js_events.mousedowns Dom_html.window trigger_long_click_mechanism in
      Lwt.return () *) 
  in
    Js.Unsafe.global##.browser##.storage##.onChanged##addListener 
      (fun changes ->
        let () = Firebug.console##log (Js.string "cnclng") in
        if not (Js.to_bool changes##.longClickToggle##.newValue) then
          Lwt.cancel promise)

(* let rec fn () =
  let ev = Lwt_js_events.mousedown Dom_html.window in
    let getting_prefs = Js.Unsafe.global##.browser##.storage##.local##get Common.prefs_query in
    let _ = getting_prefs##then_
              ~fulfilled: (fun prefs -> 
                if Js.to_bool prefs##.longClickToggle then

              )
    let _ = let open Promise.Syntax in
    let* prefs = Js.Unsafe.global##.browser##.storage##.local##get Common.prefs_query in
      if Js.to_bool prefs##.longClickToggle then
        (* invoke *)
        fn ()
      else
        ()
      let request_id = request_toggle prefs##.longClickToggleTime in
      let _ = cancel_toggle request_id in
    Promise.resolve () *)