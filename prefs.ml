open Js_of_ocaml
open Js_of_ocaml_lwt

let storage_local = Js.Unsafe.global##.browser##.storage##.local

let configure_long_click_toggle prefs =
  match Dom_html.getElementById_coerce "longClickToggle" Dom_html.CoerceTo.input with
    | None -> ()
    | Some checkbox ->
        let () = checkbox##.checked := prefs##.longClickToggle in

        let save_config checked =
          let upd = object%js 
            val longClickToggle = checked
          end in
          ignore(storage_local##set upd)
        in

        let toggle_time_input checked =
          match Dom_html.getElementById_coerce "longClickToggleTime" Dom_html.CoerceTo.input with
          | None -> ()
          | Some textbox -> textbox##.disabled := Js.bool (not (Js.to_bool checked))
        in

        let (_ : unit Lwt.t) =
          let%lwt () =
            Lwt_js_events.changes
              checkbox
              (fun ev _ ->
                Js.Opt.iter
                  (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
                  (fun input ->
                    save_config input##.checked;
                    toggle_time_input input##.checked);
                Lwt.return ()) in
          Lwt.return ()
        in
        ()

let configure_long_click_time_input prefs =
  match Dom_html.getElementById_coerce "longClickToggleTime" Dom_html.CoerceTo.input with
    | None -> ()
    | Some textbox ->
        let () = textbox##.value := prefs##.longClickToggleTime in
        let () = textbox##.disabled := Js.bool (not (Js.to_bool prefs##.longClickToggle)) in

        let (_ : unit Lwt.t) =
          let%lwt () = 
            Lwt_js_events.changes 
              textbox 
              (fun ev _ -> 
                Js.Opt.iter
                  (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
                  (fun input -> 
                    let upd = object%js 
                      val longClickToggleTime = input##.value
                    end in
                    ignore (storage_local##set upd));
                Lwt.return ()) in
          Lwt.return ()
        in
        ()

let (_ : unit Lwt.t) =
  let%lwt () = Lwt_js_events.domContentLoaded () in
    let (_ : unit Promise.t) =
      let open Promise.Syntax in
      let* curr_prefs = storage_local##get Common.prefs_query in
      let () = configure_long_click_toggle curr_prefs in
      let () = configure_long_click_time_input curr_prefs in
      Promise.resolve ()
  in
  Lwt.return ()