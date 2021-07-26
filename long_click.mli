open Js_of_ocaml

val clicked_only_left_button : Dom_html.mouseEvent Js.t -> bool

val clicked_on_passive_ele : Dom_html.mouseEvent Js.t -> bool

val is_valid_click : Dom_html.mouseEvent Js.t -> bool
