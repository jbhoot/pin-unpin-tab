module AbortSignal = struct
  type t
end

module MouseEvent = struct
  type ('t, 'ct) t =
    { target : 't
    ; currentTarget : 'ct
    ; button : int
    ; shiftKey : bool
    ; altKey : bool
    ; ctrlKey : bool
    }
end

module Events = struct
  type event_listener_options =
    { capture : bool option
    ; once : bool option
    ; passive : bool option
    ; signal : AbortSignal.t option
    }
end

external addEventListener :
     'ct
  -> string
  -> (('t, 'ct) mouseEvent -> unit)
  -> event_listener_options
  -> unit = "addEventListener"
  [@@bs.send]

module EventTarget : sig
  type ('t, 'e) name = string
  type ('t, 'e) mouse = 'e Dom.mouseEvent_like

  external addEventListener : 'ct -> string -> (('t, 'ct) ev -> unit) -> unit
    = "addEventListener"
    [@@bs.send]

  val click : (('a Dom.element_like as 't), ('t, 'e) mouse) name
    [@@bs.inline "click"]

  external asEventTargetLike : 't -> 't Dom.eventTarget_like = "%identity"
end = struct
  type ('t, 'e) name = string
  type ('t, 'e) mouse = 'e Dom.mouseEvent_like

  external addEventListener :
       ('a Dom.eventTarget_like as 't)
    -> ('t, 'e) name
    -> (('e -> unit)[@bs])
    -> unit = "addEventListener"
    [@@bs.send]

  let click = "click" [@@bs.inline]

  external asEventTargetLike : 't -> 't Dom.eventTarget_like = "%identity"
end

module Document = struct
  type event_listener_options =
    { capture : bool option
    ; once : bool option
    ; passive : bool option
    ; signal : AbortSignal.t option
    }

  external add_event_listener :
       Dom.document
    -> string
    -> (Dom.event -> unit)
    -> event_listener_options option
    -> unit = "addEventListener"
    [@@bs.send]

  let add_domContentLoaded_listener w handler opts =
    add_event_listener w "DOMContentLoaded" handler opts
end

external document : Dom.document = "document" [@@bs.val]
