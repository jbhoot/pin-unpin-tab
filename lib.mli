type app_state =
  { long_click_toggle : bool
  ; long_click_toggle_time : int
  }

val cast_to_app_state : Ojs.t -> app_state [@@js.cast]

module Query : sig
  val make :
       long_click_toggle:(bool[@js "longClickToggle"])
    -> long_click_toggle_time:(int[@js "longClickToggleTime"])
    -> Ojs.t
    [@@js.builder]
end
