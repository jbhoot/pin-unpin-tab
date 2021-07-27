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

let clicked_on_passive_ele ev =
  (* checks whether the clicked element is a <select> element or not. <select>
     (at least) on macOS does not generate mouseup, thus unintentionally
     triggering long-click.*)
  let ele = Dom_html.eventTarget ev in
  match Js.to_string ele##.tagName with
  | "SELECT" -> false
  | _ -> true

let clicked_on_passive_role ev =
  (* checks whether an ancestor of the clicked element has an 'option' role.
     elements with listbox/option roles tend to trigger long-click because they
     don't trigger mouseup. *)
  let ele = Dom_html.eventTarget ev in
  let ancestorWithActiveRole = ele##closest (Js.string "[role='option']") in
  not (Js.Opt.test ancestorWithActiveRole)

let is_valid_click ev =
  clicked_only_left_button ev
  && clicked_on_passive_ele ev && clicked_on_passive_role ev

type wait =
  | WaitUntilTimeout
  | WaitUntilMouseUp
  | WaitUntilMouseMove
  | WaitUntilDocumentScroll
  | WaitUntilElementScroll

let wait_until_timeout time =
  let%lwt () = Lwt_js.sleep time in
  Lwt.return WaitUntilTimeout

let wait_until_mouse_up () =
  let%lwt (_ : Dom_html.mouseEvent Js.t) =
    Lwt_js_events.mouseup Dom_html.window
  in
  Lwt.return WaitUntilMouseUp

let wait_until_mouse_move () =
  let%lwt (_ : Dom_html.mouseEvent Js.t) =
    Lwt_js_events.mousemove Dom_html.window
  in
  Lwt.return WaitUntilMouseMove

let wait_until_document_scroll () =
  let%lwt (_ : Dom_html.event Js.t) = Lwt_js_events.scroll Dom_html.window in
  Lwt.return WaitUntilDocumentScroll

let wait_until_element_scroll ev =
  let%lwt (_ : Dom_html.event Js.t) =
    Lwt_js_events.scroll (Dom_html.eventTarget ev)
  in
  Lwt.return WaitUntilDocumentScroll

let (_ : unit Lwt.t) =
  let%lwt () = Lwt_js_events.domContentLoaded () in
  let listener_handle = ref (Lwt.return ()) in

  let init config =
    if config##.longClickToggle then
      let%lwt () =
        Lwt_js_events.mousedowns Dom_html.window (fun ev _ ->
            if is_valid_click ev then
              let%lwt waited =
                Lwt.pick
                  [ wait_until_timeout (config##.longClickToggleTime /. 1000.)
                  ; wait_until_mouse_up ()
                  ; wait_until_mouse_move ()
                  ; wait_until_document_scroll ()
                  ; wait_until_element_scroll ev
                  ]
              in
              match waited with
              | WaitUntilMouseUp -> Lwt.return ()
              | WaitUntilMouseMove -> Lwt.return ()
              | WaitUntilDocumentScroll -> Lwt.return ()
              | WaitUntilElementScroll -> Lwt.return ()
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
      Lwt.cancel !listener_handle;
      listener_handle := init config;
      Promise.resolve ()
    in
    ()
  in

  let () = storage_all##.onChanged##addListener (fun _changes -> restart ()) in

  Lwt.return (restart ())
