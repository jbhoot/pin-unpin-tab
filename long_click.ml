open Js_of_ocaml
open Js_of_ocaml_lwt

let browser = Js.Unsafe.global##.browser
let storage_all = Js.Unsafe.global##.browser##.storage
let storage_local = Js.Unsafe.global##.browser##.storage##.local

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
  Dom_html.buttonPressed ev = Dom_html.Left_button &&
  ev##.shiftKey = Js._false &&
  ev##.ctrlKey = Js._false &&
  ev##.altKey = Js._false  

let is_valid_click : Dom_html.mouseEvent Js.t -> bool = fun ev ->
  clicked_only_left_button ev &&
  not (clicked_on_document_scrollbar ev) &&
  not (clicked_on_element_scrollbar ev)

type wait =
  | WaitUntilTimeout
  | WaitUntilMouseUp 
  | WaitUntilMouseMove

let wait_until_timeout time =
  (* Firebug.console##log time; *)
  let%lwt () = Lwt_js.sleep time in
  (* Firebug.console##log (Js.string "triggered"); *)
  Lwt.return WaitUntilTimeout

let interrupted_by_mouse_up () =
  let%lwt (_ : Dom_html.mouseEvent Js.t) = Lwt_js_events.mouseup Dom_html.window in
  (* Firebug.console##log (Js.string "mouseuped"); *)
  Lwt.return WaitUntilMouseUp

let interrupted_by_mouse_move () =
  let%lwt (_ : Dom_html.mouseEvent Js.t) = Lwt_js_events.mousemove Dom_html.window in
  (* Firebug.console##log (Js.string "mousemved"); *)
  Lwt.return WaitUntilMouseMove

let (_ : unit Lwt.t) =
  let%lwt () = Lwt_js_events.domContentLoaded () in
    let listener_handle = ref (Lwt.return ()) in

    let init config =
      (* Firebug.console##log (Js.string "initing"); *)
      if config##.longClickToggle then
        let%lwt () = 
          Lwt_js_events.mousedowns 
            Dom_html.window
            (fun ev _ -> 
              if is_valid_click ev then
                let%lwt waited = Lwt.pick [wait_until_timeout (config##.longClickToggleTime /. 1000.); interrupted_by_mouse_up (); interrupted_by_mouse_move ();] in
                  match waited with
                  | WaitUntilMouseUp -> Lwt.return ()
                  | WaitUntilMouseMove -> Lwt.return ()
                  | WaitUntilTimeout -> 
                      let _ = browser##.runtime##sendMessage (Js.string "toggle") in
                      Lwt.return ()
              else
                Lwt.return ())
        in
        Lwt.return ()
      else
        Lwt.return ()
    in

    let restart () =
      let (_ : unit Promise.t) =
        let open Promise.Syntax in
        let* config = storage_local##get Common.prefs_query in
        (* Firebug.console##log (Js.string "restarting"); *)
        (* Firebug.console##log config; *)
        Lwt.cancel !listener_handle;
        listener_handle := init config;
        Promise.resolve ()
      in ()
    in

    let () = storage_all##.onChanged##addListener
      (fun _changes -> restart ())
    
    in
    Lwt.return (restart ())