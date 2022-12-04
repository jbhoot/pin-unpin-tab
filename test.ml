external document : Dom.document = "document" [@@val]
external window : Dom.window = "window" [@@val]

module FileReader = struct
  type t

  external make : unit -> t = "FileReader" [@@bs.new]
end

module AbortSignal = struct
  type t

  external make : unit -> t = "AbortSignal" [@@bs.new]
end

type opts = { useCapture : bool }

type ('t, 'ct) ev =
  { target : 't
  ; currentTarget : 'ct
  }

module Approach1 = struct
  external listen_to_click :
    'ct -> (_[@as "click"]) -> (('t, 'ct) ev -> unit) -> opts option -> unit
    = "addEventListener"
    [@@send]

  external listen_to_dblclick :
    'ct -> (_[@as "dblclick"]) -> (('t, 'ct) ev -> unit) -> opts option -> unit
    = "addEventListener"
    [@@send]

  let eg1 =
    listen_to_click document
      (fun (event : (Dom.element, Dom.document) ev) ->
        let tgt = event.target in
        let ctgt = event.currentTarget in
        ())
      None

  let eg2 =
    listen_to_dblclick window
      (fun (event : (Dom.element, Dom.window) ev) ->
        let tgt = event.target in
        let ctgt = event.currentTarget in
        ())
      None
end

module Approach2 = struct
  (* NOTE: The polymorphic variant MUST BE "inlined". The following code does
     not work. *)
  (* type ('t, 'ct) name = *)
  (*   ([ `click of ('t, 'ct) ev -> unit *)
  (*    | `dblclick of ('t, 'ct) ev -> unit *)
  (*    ] *)
  (*   [@string]) *)
  (* external listen : 'ct -> ('t, 'ct) name -> opts option -> unit *)
  (*   = "addEventListener" *)
  (*   [@@send] *)
  (* It compiles to: *)
  (* document.addEventListener({ *)
  (*   NAME: "click", *)
  (*   VAL: (function ($$event) { *)
  (*     }) *)
  (* }, undefined); *)

  external listen :
       'ct
    -> ([ `click of ('t, 'ct) ev -> unit
        | `dblclick of ('t, 'ct) ev -> unit
        | `abort_abortsignal of (AbortSignal.t, AbortSignal.t) ev -> unit
          [@as "abort"]
        | `abort_filereader of (FileReader.t, FileReader.t) ev -> unit
          [@as "abort"]
        ]
       [@string])
    -> opts option
    -> unit = "addEventListener"
    [@@send]

  let eg1 =
    listen document
      (`click
        (fun (event : (Dom.element, Dom.document) ev) ->
          let tgt = event.target in
          let ctgt = event.currentTarget in
          ()))
      None

  let eg2 =
    listen window
      (`dblclick
        (fun (event : (Dom.element, Dom.window) ev) ->
          let tgt = event.target in
          let ctgt = event.currentTarget in
          ()))
      None

  let eg3 =
    listen (AbortSignal.make ())
      (`abort_abortsignal
        (fun event ->
          let tgt = event.target in
          let ctgt = event.currentTarget in
          ()))
      None
end

module Approach3 = struct
  type name =
    [ `click
    | `dblclick
    ]

  external listen_to_mouse_ev :
    'ct -> name -> (('t, 'ct) ev -> unit) -> opts option -> unit
    = "addEventListener"
    [@@send]

  let eg1 =
    listen_to_mouse_ev document `click
      (fun (event : (Dom.element, Dom.document) ev) ->
        let tgt = event.target in
        let ctgt = event.currentTarget in
        ())
      None

  let eg2 =
    listen_to_mouse_ev document `dblclick
      (fun (event : (Dom.element, Dom.document) ev) ->
        let tgt = event.target in
        let ctgt = event.currentTarget in
        ())
      None
end
