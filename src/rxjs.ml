open Dom_api

module Cell = struct
  type 'a t

  external make : 'a -> 'a t = "BehaviorSubject" [@@bs.new] [@@bs.module "rxjs"]

  (* getValue() == sample() primitive *)
  external get_value : 'a t -> 'a = "getValue" [@@bs.send]
end

module Stream = struct
  type 'a t
  type subscription

  (* TODO: Not sure if ('a , string) Promise.Js.t is a correct type binding.
     `string` is contentious. *)
  external from_promise : ('a, string) Promise.Js.t -> 'a t = "from"
    [@@bs.module "rxjs"]

  (* one from_event_change binding for each of input, select, textarea *)
  external from_event_change :
       InputElement.t
    -> (_[@bs.as "change"])
    -> opts:Ev.opts option
    -> ([ `change ], InputElement.t, InputElement.t) Generic_ev.t t
    = "fromEvent"
    [@@bs.module "rxjs"]

  (* one from_event_change binding for each of input, select, textarea *)
  external from_event_input :
       InputElement.t
    -> (_[@bs.as "input"])
    -> opts:Ev.opts option
    -> ([ `input ], InputElement.t, InputElement.t) Generic_ev.t t = "fromEvent"
    [@@bs.module "rxjs"]

  external from_event_DOMContentLoaded :
       Document.t
    -> (_[@bs.as "DOMContentLoaded"])
    -> opts:Ev.opts option
    -> ([ `DOMContentLoaded ], Document.t, Document.t) Generic_ev.t t
    = "fromEvent"
    [@@bs.module "rxjs"]

  external from_event_mousedown :
       Document.t
    -> (_[@bs.as "mousedown"])
    -> opts:Ev.opts option
    -> ([ `mousedown ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@bs.module "rxjs"]

  external from_event_mouseup :
       Document.t
    -> (_[@bs.as "mouseup"])
    -> opts:Ev.opts option
    -> ([ `mouseup ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@bs.module "rxjs"]

  external from_event_mousemove :
       Document.t
    -> (_[@bs.as "mousemove"])
    -> opts:Ev.opts option
    -> ([ `mousemove ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@bs.module "rxjs"]

  external from_event_scroll_e :
       Element.t
    -> (_[@bs.as "scroll"])
    -> opts:Ev.opts option
    -> ([ `scroll ], Element.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@bs.module "rxjs"]

  external from_event_scroll_d :
       Document.t
    -> (_[@bs.as "scroll"])
    -> opts:Ev.opts option
    -> ([ `scroll ], Document.t, Element.t) Mouse_ev.t t = "fromEvent"
    [@@bs.module "rxjs"]

  external from_event_pattern :
    (('a -> 'b) -> 'h_id) -> (('a -> 'b) -> 'h_id -> unit) -> ('a -> 'r) -> 'r t
    = "fromEventPattern"
    [@@bs.module "rxjs"]

  external from_event_pattern2 :
       (('a -> 'b -> 'c) -> 'h_id)
    -> (('a -> 'b -> 'c) -> 'h_id -> unit)
    -> ('a -> 'b -> 'r)
    -> 'r t = "fromEventPattern"
    [@@bs.module "rxjs"]

  external from_event_pattern3 :
       (('a -> 'b -> 'c -> 'd) -> 'h_id)
    -> (('a -> 'b -> 'c -> 'd) -> 'h_id -> unit)
    -> ('a -> 'b -> 'c -> 'r)
    -> 'r t = "fromEventPattern"
    [@@bs.module "rxjs"]

  external timer : int -> int t = "timer" [@@bs.module "rxjs"]

  external subscribe : 'a t -> ('a -> unit) -> subscription = "subscribe"
    [@@bs.send]

  external subscribeCell : 'a t -> 'a Cell.t -> subscription = "subscribe"
    [@@bs.send]

  external pipe0 : 'a t -> 'a t = "pipe" [@@bs.send]
  external pipe1 : 'a t -> ('a t -> 'b t) -> 'b t = "pipe" [@@bs.send]

  external pipe2 : 'a t -> ('a t -> 'b t) -> ('b t -> 'c t) -> 'c t = "pipe"
    [@@bs.send]

  external pipe3 :
    'a t -> ('a t -> 'b t) -> ('b t -> 'c t) -> ('c t -> 'd t) -> 'd t = "pipe"
    [@@bs.send]

  external pipe4 :
       'a t
    -> ('a t -> 'b t)
    -> ('b t -> 'c t)
    -> ('c t -> 'd t)
    -> ('d t -> 'e t)
    -> 'e t = "pipe"
    [@@bs.send]

  external pipe5 :
       'a t
    -> ('a t -> 'b t)
    -> ('b t -> 'c t)
    -> ('c t -> 'd t)
    -> ('d t -> 'e t)
    -> ('e t -> 'f t)
    -> 'f t = "pipe"
    [@@bs.send]
end

module Op = struct
  type ('a, 'b) op_fn = 'a Stream.t -> 'b Stream.t

  external map : ('a -> int -> 'b) -> ('a, 'b) op_fn = "map"
    [@@bs.module "rxjs"]

  external filter : ('a -> int -> bool) -> ('a, 'a) op_fn = "filter"
    [@@bs.module "rxjs"]

  external merge_map : ('a -> int -> 'b Stream.t) -> ('a, 'b) op_fn = "mergeMap"
    [@@bs.module "rxjs"]

  external take_until : 'b Stream.t -> ('a, 'a) op_fn = "takeUntil"
    [@@bs.module "rxjs"]

  external tap : ('a -> unit) -> ('a, 'a) op_fn = "tap" [@@bs.module "rxjs"]
  external startWith : 'a -> ('a, 'a) op_fn = "startWith" [@@bs.module "rxjs"]

  external withLatestFrom : 'b Cell.t -> ('a -> 'b -> 'c) -> ('a, 'c) op_fn
    = "withLatestFrom"
    [@@bs.module "rxjs"]

  external merge2 : 'a Stream.t -> 'a Stream.t -> 'a Stream.t = "merge"
    [@@bs.module "rxjs"]

  external merge3 : 'a Stream.t -> 'a Stream.t -> 'a Stream.t -> 'a Stream.t
    = "merge"
    [@@bs.module "rxjs"]

  external merge4 :
    'a Stream.t -> 'a Stream.t -> 'a Stream.t -> 'a Stream.t -> 'a Stream.t
    = "merge"
    [@@bs.module "rxjs"]

  external merge5 :
       'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t
    -> 'a Stream.t = "merge"
    [@@bs.module "rxjs"]

  external combineLatest2 :
    'a Stream.t -> 'b Stream.t -> ('a -> 'b -> 'c) -> 'c Stream.t
    = "combineLatest"
    [@@bs.module "rxjs"]

  external combineLatest3 :
       'a Stream.t
    -> 'b Stream.t
    -> 'c Stream.t
    -> ('a -> 'b -> 'c -> 'd)
    -> 'd Stream.t = "combineLatest"
    [@@bs.module "rxjs"]

  external combineLatest4 :
       'a Stream.t
    -> 'b Stream.t
    -> 'c Stream.t
    -> 'd Stream.t
    -> ('a -> 'b -> 'c -> 'd -> 'e)
    -> 'e Stream.t = "combineLatest"
    [@@bs.module "rxjs"]

  external combineLatest5 :
       'a Stream.t
    -> 'b Stream.t
    -> 'c Stream.t
    -> 'd Stream.t
    -> 'e Stream.t
    -> ('a -> 'b -> 'c -> 'd -> 'e -> 'f)
    -> 'f Stream.t = "combineLatest"
    [@@bs.module "rxjs"]

  let hold stream init_val =
    let cell = Cell.make init_val in
    let _ = Stream.subscribeCell stream cell in
    cell
end
