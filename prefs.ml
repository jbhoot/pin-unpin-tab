open Js_of_ocaml
open Js_of_ocaml_lwt

let handler () =
  let open Promise.Syntax in
  let storage = Js.Unsafe.global##.browser##.storage##.local in
  let* curr_prefs = storage##get Common.prefs_query in
  let () = Firebug.console##log curr_prefs in
  let () = match Dom_html.getElementById_coerce "longClickToggle" Dom_html.CoerceTo.input with
    | None -> ()
    | Some checkbox ->
        let () = checkbox##.checked := curr_prefs##.longClickToggle
        in
        let change_handler checked =
          let upd = object%js 
            val longClickToggle = checked
          end
          in  
          let* res = storage##set upd in
          Promise.resolve res
        in
        let update_time_input checked =
          match Dom_html.getElementById_coerce "longClickToggleTime" Dom_html.CoerceTo.input with
          | None -> ()
          | Some textbox -> 
              let disabled = not (Js.to_bool checked) in
              let () = textbox##.disabled := Js.bool disabled in
              ()
        in
        let _ = Dom_html.addEventListener
          checkbox
          Dom_html.Event.change
          (Dom_html.handler (fun ev ->
            Js.Opt.case
              (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
              (fun () -> Js._true)
              (fun target ->
                let checked = target##.checked in
                let _ = change_handler checked in
                let _ = update_time_input checked in
                Js._true)))
          Js._true
        in ()
  in
  let () = match Dom_html.getElementById_coerce "longClickToggleTime" Dom_html.CoerceTo.input with
  | None -> ()
  | Some textbox ->
      let () = textbox##.value := curr_prefs##.longClickToggleTime in
      let disabled = not (Js.to_bool curr_prefs##.longClickToggle) in
      let () = textbox##.disabled := Js.bool disabled in
      let change_handler ev =
        Js.Opt.map
        (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
        (fun target -> 
          let upd = object%js 
            val longClickToggleTime = target##.value
          end
          in
          let* res = storage##set upd in
          Promise.resolve res)
      in
      let _ = Dom_html.addEventListener
        textbox
        Dom_html.Event.change
        (Dom_html.handler (fun ev -> let _ = change_handler ev in Js._true))
        Js._true
      in ()
  in
  Promise.resolve curr_prefs

  
let _ =
  let%lwt _ = Lwt_js_events.domContentLoaded () in
    let _ = handler () in
    Lwt.return ()