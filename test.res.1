@val external document: Dom.document = "document"
@val external window: Dom.window = "window"

type opts = {useCapture: bool}

type ev<'t, 'ct> = {
  target: 't,
  currentTarget: 'ct,
}

module FileReader = {
  type t
  @new external make: unit => t = "FileReader"
}

module AbortSignal = {
  type t
  @new external make: unit => t = "AbortSignal"
}

module Approach1 = {
  @send
  external listen_to_click: (
    'ct,
    @as("click") _,
    ev<'t, 'ct> => unit,
    option<opts>,
  ) => unit = "addEventListener"

  @send
  external listen_to_dblclick: (
    'ct,
    @as("dblclick") _,
    ev<'t, 'ct> => unit,
    option<opts>,
  ) => unit = "addEventListener"

  let eg1 = listen_to_click(
    document,
    (event: ev<Dom.element, Dom.document>) => {
      let tgt = event.target
      let ctgt = event.currentTarget
    },
    None,
  )

  let eg2 = listen_to_dblclick(
    window,
    (event: ev<Dom.element, Dom.window>) => {
      let tgt = event.target
      let ctgt = event.currentTarget
    },
    None,
  )
}

module Approach2 = {
  @send
  external listen: (
    'ct,
    @string
    [
      | #click(ev<'t, 'ct> => unit)
      | #dblclick(ev<'t, 'ct> => unit)
      | #abort(ev<FileReader.t, FileReader.t> => unit)
      | @as("abort") #abort2(ev<AbortSignal.t, AbortSignal.t> => unit)
    ],
    option<opts>,
  ) => unit = "addEventListener"

  let eg1 = listen(
    document,
    #click(
      (event: ev<Dom.element, Dom.document>) => {
        let tgt = event.target
        let ctgt = event.currentTarget
      },
    ),
    None,
  )

  let eg2 = listen(
    window,
    #dblclick(
      (event: ev<Dom.element, Dom.window>) => {
        let tgt = event.target
        let ctgt = event.currentTarget
      },
    ),
    None,
  )

  let eg3 = listen(
    AbortSignal.make(),
    #abort2(
      event => {
        let tgt = event.target
        let ctgt = event.currentTarget
      },
    ),
    None,
  )
}

module Approach3 = {
  type name = [#click | #dblclick]

  @send
  external listen_to_mouse_ev: (
    'ct,
    name,
    ev<'t, 'ct> => unit,
    option<opts>,
  ) => unit = "addEventListener"

  let eg1 = listen_to_mouse_ev(
    document,
    #click,
    (event: ev<Dom.element, Dom.document>) => {
      let tgt = event.target
      let ctgt = event.currentTarget
    },
    None,
  )

  let eg2 = listen_to_mouse_ev(
    document,
    #dblclick,
    (event: ev<Dom.element, Dom.document>) => {
      let tgt = event.target
      let ctgt = event.currentTarget
    },
    None,
  )
}
