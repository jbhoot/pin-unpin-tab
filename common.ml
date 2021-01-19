open Js_of_ocaml

let prefs_query = 
  object%js
    val longClickToggle = Js._true
    val longClickToggleTime = 600
  end