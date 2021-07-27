open Js_of_ocaml

let empty_object = object%js end

let prefs_query =
  object%js
    val longClickToggle = Js._true

    val longClickToggleTime = 600
  end
