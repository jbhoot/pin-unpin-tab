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
  external closest : Dom.element -> string -> Dom.element option = "closest"
    [@@bs.send] [@@bs.return nullable]
end

module Ev = struct
  type opts =
    { capture : bool option
    ; once : bool option
    ; passive : bool option
    ; signal : AbortSignal.t option
    }

  type ('t, 'ct) generic_ev =
    { target : 't
    ; currentTarget : 'ct
    }

  type ('t, 'ct) mouse_ev =
    { target : 't
    ; currentTarget : 'ct
    ; button : int (* todo: represent ev.button as a polymorphic variant *)
    ; shiftKey : bool
    ; altKey : bool
    ; ctrlKey : bool
    }

  external listen :
       'ct
    -> ([ `DOMContentLoaded of ('t, 'ct) generic_ev -> unit
        | `click of ('t, 'ct) mouse_ev -> unit
        | `dblclick of ('t, 'ct) mouse_ev -> unit
        | `mouseup of ('t, 'ct) mouse_ev -> unit
        | `mousedown of ('t, 'ct) mouse_ev -> unit
        | `mousemove of ('t, 'ct) mouse_ev -> unit
        | `scroll of ('t, 'ct) generic_ev -> unit
        | `abort_abortsignal of
          (AbortSignal.t, AbortSignal.t) generic_ev -> unit
          [@as "abort"]
        | `abort_filereader of (FileReader.t, FileReader.t) generic_ev -> unit
          [@as "abort"]
        ]
       [@string])
    -> opts option
    -> unit = "addEventListener"
    [@@bs.send]
end

external set_timeout : (unit -> unit) -> float -> int = "setTimeout" [@@bs.val]
external clear_timeout : int -> unit = "clearTimeout" [@@bs.val]
external document : Dom.document = "document" [@@bs.val]
external window : Dom.window = "window" [@@bs.val]
