open Dom_api

module Cell = struct
  type 'a t

  external make : 'a -> 'a t = "BehaviorSubject" [@@mel.new] [@@mel.module "rxjs"]

  (* getValue() == sample() primitive *)
  external get_value : 'a t -> 'a = "getValue" [@@mel.send]
end

module Stream = struct
  type 'a t
  type subscription

  (* TODO: Not sure if ('a , string) Promise.Js.t is a correct type binding.
     `string` is contentious. *)
  external from_promise : ('a, string) Promise.Js.t -> 'a t = "from"
    [@@mel.module "rxjs"]

  (* one from_event_change binding for each of input, select, textarea *)
  external from_event_change :
       InputElement.t
    -> (_[@mel.as "change"])
    -> opts:Ev.opts option
    -> ([ `change ], InputElement.t, InputElement.t) Generic_ev.t t
    = "fromEvent"
    [@@mel.module "rxjs"]

  (* one from_event_change binding for each of input, select, textarea *)
  external from_event_input :
       InputElement.t
    -> (_[@mel.as "input"])
    -> opts:Ev.opts option
    -> ([ `input ], InputElement.t, InputElement.t) Generic_ev.t t = "fromEvent"
    [@@mel.module "rxjs"]

  external from_event_DOMContentLoaded :
       Document.t
    -> (_[@mel.as "DOMContentLoaded"])
    -> opts:Ev.opts option
    -> ([ `DOMContentLoaded ], Document.t, Document.t) Generic_ev.t t
    = "fromEvent"
    [@@mel.module "rxjs"]

  external from_event_mousedown :
       Document.t
    -> (_[@mel.as "mousedown"])
    -> opts:Ev.opts option
    -> ([ `mousedown ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@mel.module "rxjs"]

  external from_event_mouseup :
       Document.t
    -> (_[@mel.as "mouseup"])
    -> opts:Ev.opts option
    -> ([ `mouseup ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@mel.module "rxjs"]

  external from_event_mousemove :
       Document.t
    -> (_[@mel.as "mousemove"])
    -> opts:Ev.opts option
    -> ([ `mousemove ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@mel.module "rxjs"]

  external from_event_scroll_e :
       Element.t
    -> (_[@mel.as "scroll"])
    -> opts:Ev.opts option
    -> ([ `scroll ], Element.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@mel.module "rxjs"]

  external from_event_scroll_d :
       Document.t
    -> (_[@mel.as "scroll"])
    -> opts:Ev.opts option
    -> ([ `scroll ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@mel.module "rxjs"]

  external from_event_pattern :
    (('a -> 'b) -> 'h_id) -> (('a -> 'b) -> 'h_id -> unit) -> ('a -> 'r) -> 'r t
    = "fromEventPattern"
    [@@mel.module "rxjs"]

  external from_event_pattern2 :
       (('a -> 'b -> 'c) -> 'h_id)
    -> (('a -> 'b -> 'c) -> 'h_id -> unit)
    -> ('a -> 'b -> 'r)
    -> 'r t = "fromEventPattern"
    [@@mel.module "rxjs"]

  external from_event_pattern3 :
       (('a -> 'b -> 'c -> 'd) -> 'h_id)
    -> (('a -> 'b -> 'c -> 'd) -> 'h_id -> unit)
    -> ('a -> 'b -> 'c -> 'r)
    -> 'r t = "fromEventPattern"
    [@@mel.module "rxjs"]

  external timer : int -> int t = "timer" [@@mel.module "rxjs"]

  external subscribe : 'a t -> ('a -> unit) -> subscription = "subscribe"
    [@@mel.send]

  external subscribeCell : 'a t -> 'a Cell.t -> subscription = "subscribe"
    [@@mel.send]

  external pipe0 : 'a t -> 'a t = "pipe" [@@mel.send]
  external pipe1 : 'a t -> ('a t -> 'b t) -> 'b t = "pipe" [@@mel.send]

  external pipe2 : 'a t -> ('a t -> 'b t) -> ('b t -> 'c t) -> 'c t = "pipe"
    [@@mel.send]

  external pipe3 :
    'a t -> ('a t -> 'b t) -> ('b t -> 'c t) -> ('c t -> 'd t) -> 'd t = "pipe"
    [@@mel.send]

  external pipe4 :
       'a t
    -> ('a t -> 'b t)
    -> ('b t -> 'c t)
    -> ('c t -> 'd t)
    -> ('d t -> 'e t)
    -> 'e t = "pipe"
    [@@mel.send]

  external pipe5 :
       'a t
    -> ('a t -> 'b t)
    -> ('b t -> 'c t)
    -> ('c t -> 'd t)
    -> ('d t -> 'e t)
    -> ('e t -> 'f t)
    -> 'f t = "pipe"
    [@@mel.send]
end

module Op = struct
  type ('a, 'b) op_fn = 'a Stream.t -> 'b Stream.t

  external map : ('a -> int -> 'b) -> ('a, 'b) op_fn = "map"
    [@@mel.module "rxjs"]

  external filter : ('a -> int -> bool) -> ('a, 'a) op_fn = "filter"
    [@@mel.module "rxjs"]

  external merge_map : ('a -> int -> 'b Stream.t) -> ('a, 'b) op_fn = "mergeMap"
    [@@mel.module "rxjs"]

  external take_until : 'b Stream.t -> ('a, 'a) op_fn = "takeUntil"
    [@@mel.module "rxjs"]

  external tap : ('a -> unit) -> ('a, 'a) op_fn = "tap" [@@mel.module "rxjs"]
  external startWith : 'a -> ('a, 'a) op_fn = "startWith" [@@mel.module "rxjs"]

  external withLatestFrom : 'b Cell.t -> ('a -> 'b -> 'c) -> ('a, 'c) op_fn
    = "withLatestFrom"
    [@@mel.module "rxjs"]

  external merge2 : 'a Stream.t -> 'a Stream.t -> 'a Stream.t = "merge"
    [@@mel.module "rxjs"]

  external merge3 : 'a Stream.t -> 'a Stream.t -> 'a Stream.t -> 'a Stream.t
    = "merge"
    [@@mel.module "rxjs"]

  external merge4 :
    'a Stream.t -> 'a Stream.t -> 'a Stream.t -> 'a Stream.t -> 'a Stream.t
    = "merge"
    [@@mel.module "rxjs"]

  external merge5 :
       'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t = "merge"
    [@@mel.module "rxjs"]

  external combineLatest2 :
    'a Stream.t -> 'b Stream.t -> ('a -> 'b -> 'c) -> 'c Stream.t
    = "combineLatest"
    [@@mel.module "rxjs"]

  external combineLatest3 :
       'a Stream.t
    -> 'b Stream.t
    -> 'c Stream.t
    -> ('a -> 'b -> 'c -> 'd)
    -> 'd Stream.t = "combineLatest"
    [@@mel.module "rxjs"]

  external combineLatest4 :
       'a Stream.t
    -> 'b Stream.t
    -> 'c Stream.t
    -> 'd Stream.t
    -> ('a -> 'b -> 'c -> 'd -> 'e)
    -> 'e Stream.t = "combineLatest"
    [@@mel.module "rxjs"]

  external combineLatest5 :
       'a Stream.t
    -> 'b Stream.t
    -> 'c Stream.t
    -> 'd Stream.t
    -> 'e Stream.t
    -> ('a -> 'b -> 'c -> 'd -> 'e -> 'f)
    -> 'f Stream.t = "combineLatest"
    [@@mel.module "rxjs"]

  let hold stream init_val =
    let cell = Cell.make init_val in
    let _ = Stream.subscribeCell stream cell in
    cell
end
