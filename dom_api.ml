module AbortSignal = struct
  type t
end

module Window = struct
  type event_listener_options =
    { capture : bool option
    ; once : bool option
    ; passive : bool option
    ; signal : AbortSignal.t
    }

  (* todo: turn event type (string) into a polymorphic variant *)
  external add_event_listener :
    Dom.window -> string -> (Dom.event -> unit) -> unit = "addEventListener"
    [@@bs.send]

  external add_event_listener_2 :
    Dom.window -> string -> (Dom.event -> unit) -> bool -> unit
    = "addEventListener"
    [@@bs.send]

  external add_event_listener_3 :
       Dom.window
    -> string
    -> (Dom.event -> unit)
    -> event_listener_options
    -> unit = "addEventListener"
    [@@bs.send]
end

external window : Dom.window = "window" [@@bs.val]
