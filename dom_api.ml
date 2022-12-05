module FileReader = struct
  type t

  external make : unit -> t = "FileReader" [@@bs.new]
end

module AbortSignal = struct
  type t

  external make : unit -> t = "AbortSignal" [@@bs.new]
end

module AbortController = struct
  type t

  external make : unit -> t = "AbortController" [@@bs.new]
  external signal : t -> AbortSignal.t = "signal" [@@bs.get]
  external abort : t -> 'reason option -> unit = "abort" [@@bs.send]
end

module Element = struct
  type t

  external closest : t -> string -> t option = "closest"
    [@@bs.send] [@@bs.return nullable]
end

module Document = struct
  type t

  external get_element_by_id : t -> string -> Element.t option
    = "getElementById"
    [@@bs.send]
end

module Window = struct
  type t
end

module Generic_ev = struct
  type ('t, 'ct) t

  external target : ('t, 'ct) t -> 't = "target" [@@bs.get]
  external current_target : ('t, 'ct) t -> 'ct = "currentTarget" [@@bs.get]
end

module Mouse_ev = struct
  (* include Generic_ev *)

  type ('t, 'ct) t

  external target : ('t, 'ct) t -> 't = "target" [@@bs.get]
  external current_target : ('t, 'ct) t -> 'ct = "currentTarget" [@@bs.get]

  (* todo: represent ev.button as a polymorphic variant *)
  external button : ('t, 'ct) t -> int = "button" [@@bs.get]
  external shift_key : ('t, 'ct) t -> bool = "shiftKey" [@@bs.get]
  external alt_key : ('t, 'ct) t -> bool = "altKey" [@@bs.get]
  external ctrl_key : ('t, 'ct) t -> bool = "ctrlKey" [@@bs.get]
end

module Ev = struct
  type opts =
    { capture : bool option
    ; once : bool option
    ; passive : bool option
    ; signal : AbortSignal.t option
    }

  external listen :
       'ct
    -> ([ `DOMContentLoaded of ('t, 'ct) Generic_ev.t -> unit
        | `click of ('t, 'ct) Mouse_ev.t -> unit
        | `dblclick of ('t, 'ct) Mouse_ev.t -> unit
        | `mouseup of ('t, 'ct) Mouse_ev.t -> unit
        | `mousedown of ('t, 'ct) Mouse_ev.t -> unit
        | `mousemove of ('t, 'ct) Mouse_ev.t -> unit
        | `scroll of ('t, 'ct) Generic_ev.t -> unit
        | `abort_abortsignal of
          (AbortSignal.t, AbortSignal.t) Generic_ev.t -> unit
          [@as "abort"]
        | `abort_filereader of (FileReader.t, FileReader.t) Generic_ev.t -> unit
          [@as "abort"]
        ]
       [@string])
    -> opts option
    -> unit = "addEventListener"
    [@@bs.send]
end

external set_timeout : (unit -> unit) -> float -> int = "setTimeout" [@@bs.val]
external clear_timeout : int -> unit = "clearTimeout" [@@bs.val]
external document : Document.t = "document" [@@bs.val]
external window : Window.t = "window" [@@bs.val]
