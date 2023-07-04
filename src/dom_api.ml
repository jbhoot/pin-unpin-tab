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
  type t = Dom.element

  external closest : t -> string -> t option = "closest"
    [@@bs.send] [@@bs.return nullable]

  external query_selector : t -> string -> t = "querySelector" [@@bs.send]

  external query_selector_opt : t -> string -> t option = "querySelector"
    [@@bs.send]

  external set_attribute : t -> string -> string -> unit = "setAttribute"
    [@@bs.send]
end

module InputElement = struct
  type t

  external from_element : Element.t -> t = "%identity"
  external get_value : t -> string = "value" [@@bs.get]
  external set_value : t -> string -> unit = "value" [@@bs.set]
  external get_disabled : t -> bool = "disabled" [@@bs.get]
  external set_disabled : t -> bool -> unit = "disabled" [@@bs.set]

  (* todo: should these belong to a separate CheckboxElement or
     RadioCheckboxElement? The standard clubs the properties into an
     HTMLInputElement though.
     https://html.spec.whatwg.org/multipage/input.html#dom-input-checked *)
  external get_checked : t -> bool = "checked" [@@bs.get]
  external set_checked : t -> bool -> unit = "checked" [@@bs.set]
end

module Document = struct
  type t = Dom.document

  external get_element_by_id : t -> string -> Element.t = "getElementById"
    [@@bs.send]

  external get_element_by_id_opt : t -> string -> Element.t option
    = "getElementById"
    [@@bs.send] [@@bs.return nullable]

  external query_selector : t -> string -> Element.t = "querySelector"
    [@@bs.send]

  external query_selector_opt : t -> string -> Element.t option
    = "querySelector"
    [@@bs.send] [@@bs.return nullable]
end

module Window = struct
  type t = Dom.window
end

module Base_ev (T : sig
  type ('typ, 'ct, 't) t
end) =
struct
  external type_ : ('typ, 'ct, 't) T.t -> 'typ = "type" [@@bs.get]

  external current_target : ('typ, 'ct, 't) T.t -> 'ct = "currentTarget"
    [@@bs.get]

  external target : ('typ, 'ct, 't) T.t -> 't = "target" [@@bs.get]
end

module Generic_ev = struct
  type ('typ, 'ct', 't) t

  include Base_ev (struct
    type nonrec ('typ, 'ct', 't) t = ('typ, 'ct', 't) t
  end)
end

module Mouse_ev = struct
  type ('typ, 'ct', 't) t

  include Base_ev (struct
    type nonrec ('typ, 'ct', 't) t = ('typ, 'ct', 't) t
  end)

  (* todo: represent ev.button as a polymorphic variant *)
  external button : ('typ, 'ct', 't) t -> int = "button" [@@bs.get]
  external shift_key : ('typ, 'ct', 't) t -> bool = "shiftKey" [@@bs.get]
  external alt_key : ('typ, 'ct', 't) t -> bool = "altKey" [@@bs.get]
  external ctrl_key : ('typ, 'ct', 't) t -> bool = "ctrlKey" [@@bs.get]
end

module Ev = struct
  type opts =
    { capture : bool option
    ; once : bool option
    ; passive : bool option
    ; signal : AbortSignal.t option
    }

  external l :
       Document.t
    -> (_[@bs.as "DOMContentLoaded"])
    -> (([ `DOMContentLoaded ], 't, Document.t) Generic_ev.t -> unit)
    -> unit = "addEventListener"
    [@@bs.send]

  (* An example against the following style: *)
  (* external listen : 'ct -> ([`abort of ([ `abort ], 'ct, 't) Generic_ev.t ->
     unit [@bs.string]) -> unit = "addEventListener" [@@bs.send] *)
  (* The above approach works when the first arg 'ct is correctly specified.
     This doesn't work when the call site is located in a function to which this
     first arg was passed as an argument. Within the function, this argument can
     never be inferred correctly if the listener doesn't make use of target or
     current_target ever. So if we pass an argument of a different type from
     what we want, then everything will compile, but in the resulting js code,
     the listener will be attached to a wrong object. *)
  (* e.g., when `fun set_abortable_timeout callback time
     signal_to_abort_long_click` used `listen_with_opts (`abort_abortsignal
     handler) opts` style, it ended up being a wrongly inferred type because
     there was no way to tell that signal_to_abort_long_click was an
     AbortController.t, not AbortSignal.t *)
  (* So, fixed type is needed instead of 'ct, no matter how tiresome, when
     ev.target and ev.current_target are not used in handler, thus ending up
     with a weakly inferred 'ct. *)
  external on_abort :
       AbortSignal.t
    -> (_[@bs.as "abort"])
    -> (([ `abort ], AbortSignal.t, AbortSignal.t) Generic_ev.t -> unit)
    -> opts:opts option
    -> unit = "addEventListener"
    [@@bs.send]

  external listen :
       'ct
    -> ([ (* TODO: Document is always the 'ct == currentTarget. 't == target
             could be either of document or window. *)
          `DOMContentLoaded of
          ([ `DOMContentLoaded ], 'ct', 't) Generic_ev.t -> unit
        | `click of ([ `click ], 'ct, 't) Mouse_ev.t -> unit
        | `dblclick of ([ `dblclick ], 'ct, 't) Mouse_ev.t -> unit
        | `mouseup of ([ `mouseup ], 'ct, 't) Mouse_ev.t -> unit
        | `mousedown of ([ `mousedown ], 'ct, 't) Mouse_ev.t -> unit
        | `mousemove of ([ `mousemove ], 'ct, 't) Mouse_ev.t -> unit
        | (* TODO: Both document and element types can be a 'ct ==
             currentTarget. Also figure out what the 't == `target` could be. *)
          `scroll of
          ([ `scroll ], 'ct', 't) Generic_ev.t -> unit
        ]
       [@bs.string])
    -> unit = "addEventListener"
    [@@bs.send]

  external listen_with_opts :
       'ct
    -> ([ `DOMContentLoaded of
          ([ `DOMContentLoaded ], 'ct', 't) Generic_ev.t -> unit
        | `click of ([ `click ], 'ct', 't) Mouse_ev.t -> unit
        | `dblclick of ([ `dblclick ], 'ct', 't) Mouse_ev.t -> unit
        | `mouseup of ([ `mouseup ], 'ct', 't) Mouse_ev.t -> unit
        | `mousedown of ([ `mousedown ], 'ct', 't) Mouse_ev.t -> unit
        | `mousemove of ([ `mousemove ], 'ct', 't) Mouse_ev.t -> unit
        | `scroll of ([ `scroll ], 'ct', 't) Generic_ev.t -> unit
        ]
       [@bs.string])
    -> opts
    -> unit = "addEventListener"
    [@@bs.send]
end

external set_timeout : (unit -> unit) -> int -> int = "setTimeout" [@@bs.val]
external clear_timeout : int -> unit = "clearTimeout" [@@bs.val]
external document : Document.t = "document" [@@bs.val]
external window : Window.t = "window" [@@bs.val]
