(* open Js_of_ocaml
open Js_of_ocaml_lwt

let storage_local = Js.Unsafe.global##.browser##.storage##.local

let configure_long_click_toggle prefs =
  match
    Dom_html.getElementById_coerce "longClickToggle" Dom_html.CoerceTo.input
  with
  | None -> ()
  | Some checkbox ->
    let () = checkbox##.checked := prefs##.longClickToggle in

    let save_config checked =
      let upd =
        object%js
          val longClickToggle = checked
        end
      in
      ignore (storage_local##set upd)
    in

    let toggle_time_input checked =
      match
        Dom_html.getElementById_coerce "longClickToggleTime"
          Dom_html.CoerceTo.input
      with
      | None -> ()
      | Some textbox -> textbox##.disabled := Js.bool (not (Js.to_bool checked))
    in

    let (_ : unit Lwt.t) =
      let%lwt () =
        Lwt_js_events.changes checkbox (fun ev _ ->
            Js.Opt.iter
              (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
              (fun input ->
                save_config input##.checked;
                toggle_time_input input##.checked);
            Lwt.return ())
      in
      Lwt.return ()
    in
    ()

let configure_long_click_time_input prefs =
  match
    Dom_html.getElementById_coerce "longClickToggleTime" Dom_html.CoerceTo.input
  with
  | None -> ()
  | Some textbox ->
    let () = textbox##.value := prefs##.longClickToggleTime in
    let () =
      textbox##.disabled := Js.bool (not (Js.to_bool prefs##.longClickToggle))
    in

    let (_ : unit Lwt.t) =
      let%lwt () =
        Lwt_js_events.changes textbox (fun ev _ ->
            Js.Opt.iter
              (Dom_html.CoerceTo.input (Dom_html.eventTarget ev))
              (fun input ->
                let upd =
                  object%js
                    val longClickToggleTime = input##.value
                  end
                in
                ignore (storage_local##set upd));
            Lwt.return ())
      in
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
  Lwt.return () *)

(* This file is part of the ocaml-vdom package, released under the terms of an MIT-like license.     *)
(* See the attached LICENSE file.                                                                    *)
(* Copyright 2016 by LexiFi.                                                                         *)

open Vdom

let update _ = function
  | `Click -> Js_browser.Date.now ()

let init = 0.

let view n =
  let t = Js_browser.Date.new_date n in
  div
    [
      div [text (Printf.sprintf "protocol: %S" (Js_browser.Location.protocol (Js_browser.Window.location Js_browser.window)))];
      div [text (Printf.sprintf "Number of milliseconds: %f" n)];
      div [text (Printf.sprintf "ToDateString: %s" (Js_browser.Date.to_date_string t))];
      div [text (Printf.sprintf "ToLocaleString: %s" (Js_browser.Date.to_locale_string t))];
      div [input [] ~a:[onclick (fun _ -> `Click); type_button; value "Update"]]
    ]

let app = simple_app ~init ~view ~update ()


open Js_browser

let run () = Vdom_blit.run app |> Vdom_blit.dom |> Element.append_child (Document.body document)
let () = Window.set_onload window run