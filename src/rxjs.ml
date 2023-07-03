open Dom_api

module Stream = struct
  type 'a t
  type observer
  type subscription
  type evtype

  (* TODO: Not sure if ('a , string) Promise.Js.t is a correct type binding.
     `string` is contentious. *)
  external from_promise : ('a, string) Promise.Js.t -> 'a t = "from"
    [@@bs.module "rxjs"]

  (* Alternative approach, but obsolete now that 'typ needs to be the same as
     the given event type value. *)
  (* external from_event_change : *)
  (*   'ct -> (_[@bs.as "change"]) -> ('typ, 'ct, Dom.element) Generic_ev.t t *)
  (*   = "fromEvent" *)
  (*   [@@bs.module "rxjs"] *)

  (* one from_event_change binding for each of input, select, textarea *)
  external from_event_change :
       InputElement.t
    -> [ `change ]
    -> ([ `change ], InputElement.t, InputElement.t) Generic_ev.t t
    = "fromEvent"
    [@@bs.module "rxjs"]

  (* one from_event_change binding for each of input, select, textarea *)
  external from_event_input :
       InputElement.t
    -> [ `input ]
    -> ([ `input ], InputElement.t, InputElement.t) Generic_ev.t t
    = "fromEvent"
    [@@bs.module "rxjs"]

  external subscribe : 'a t -> ('a -> unit) -> subscription = "subscribe"
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

  external filter : ('a -> int -> bool) -> ('a, 'b) op_fn = "filter"
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
end
