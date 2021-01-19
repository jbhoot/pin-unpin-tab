open Js_of_ocaml
open Js_of_ocaml_lwt

let storage = Js.Unsafe.global##.browser##.storage##.local

let configure_long_click_toggle prefs =
  match Dom_html.getElementById_coerce "longClickToggle" Dom_html.CoerceTo.input with
    | None -> ()
    | Some checkbox ->
        checkbox##.checked := prefs##.longClickToggle;
        let save_config checked =
          let upd = object%js 
            val longClickToggle = checked
          end in
          ignore(storage##set upd)
        in
        let toggle_time_input checked =
          match Dom_html.getElementById_coerce "longClickToggleTime" Dom_html.CoerceTo.input with
          | None -> ()
          | Some textbox -> textbox##.disabled := Js.bool (not (Js.to_bool checked))
        in
        ignore(Dom_html.addEventListener
          checkbox
          Dom_html.Event.change
          (Dom_html.handler (fun ev ->
            Js.Opt.iter
              (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
              (fun input ->
                save_config input##.checked;
                toggle_time_input input##.checked);
            Js._true))
          Js._true)

let configure_long_click_time_input prefs =
  match Dom_html.getElementById_coerce "longClickToggleTime" Dom_html.CoerceTo.input with
    | None -> ()
    | Some textbox ->
        textbox##.value := prefs##.longClickToggleTime;
        textbox##.disabled := Js.bool (not (Js.to_bool prefs##.longClickToggle));
        ignore(Dom_html.addEventListener
          textbox
          Dom_html.Event.change
          (Dom_html.handler (fun ev -> 
            Js.Opt.iter
              (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
              (fun input -> 
                let upd = object%js 
                  val longClickToggleTime = input##.value
                end in
                ignore (storage##set upd));
            Js._true))
          Js._true)


let _ =
  let%lwt _ = Lwt_js_events.domContentLoaded () in
    let open Promise.Syntax in
    ignore(let* curr_prefs = storage##get Common.prefs_query in
      configure_long_click_toggle curr_prefs;
      configure_long_click_time_input curr_prefs;
      Promise.resolve ());
    Lwt.return ()