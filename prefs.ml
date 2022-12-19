open Dom_api
open Tea.Html2
module A = Tea.Html2.Attributes
module E = Tea.Html2.Events

module F_args = struct
  let id = "PreferenceForm"

  type field =
    | Long_click_toggle
    | Long_click_toggle_time

  let field_id field =
    match field with
    | Long_click_toggle -> "Long_click_toggle"
    | Long_click_toggle_time -> "Long_click_toggle_time"

  type input =
    { long_click_toggle : bool
    ; long_click_toggle_time : string
    }

  type output =
    | Toggle_with_long_click of int
    | Dont_toggle_with_long_click

  type problem =
    | Field_error of field * string
    | Form_error of string

  let parse input =
    let parse_long_click_toggle value =
      match value with
      | true -> Ok true
      | false -> Ok false
    in
    let parse_long_click_toggle_time value =
      match value |> Belt.Int.fromString with
      | Some v -> Ok v
      | None ->
        Error
          [ Field_error
              (Long_click_toggle_time, "Enter the time in milliseconds")
          ]
    in
    match
      ( input.long_click_toggle |> parse_long_click_toggle
      , input.long_click_toggle_time |> parse_long_click_toggle_time )
    with
    | Ok long_click_toggle, Ok long_click_toggle_time -> (
      match long_click_toggle with
      | true -> Ok (Toggle_with_long_click long_click_toggle_time)
      | false -> Ok Dont_toggle_with_long_click)
    | long_click_toggle_res, long_click_toggle_time_res ->
      Error
        ((long_click_toggle_res |> Form.extract_problems)
        @ (long_click_toggle_time_res |> Form.extract_problems))

  let init_input init =
    match init with
    | Some init -> init
    | None -> { long_click_toggle = false; long_click_toggle_time = "" }
end

module F = Form.Make (F_args)

type model = F.t

type msg =
  | Filled_long_click_toggle of bool
  | Filled_long_click_toggle_time of string
  | Got_stored_prefs of (Common.Storage_args.t, string) result
  | Saved_prefs of (unit, string) result

let view (m : model) =
  form
    [ A.name F.id; A.novalidate true ]
    [ h1 [] [ text "Preferences" ]
    ; div []
        [ input'
            [ A.type' "checkbox"
            ; A.id (F.Field.to_id Long_click_toggle)
            ; A.name (F.Field.to_id Long_click_toggle)
            ; A.value (F.Field.to_id Long_click_toggle)
            ; A.checked m.input.long_click_toggle
            ; E.onCheck (fun v -> Filled_long_click_toggle v)
            ]
            []
        ; label
            [ A.for' (F.Field.to_id Long_click_toggle) ]
            [ text "Pin / unpin on holding left click" ]
        ]
    ; div []
        [ label
            [ A.for' (F.Field.to_id Long_click_toggle_time) ]
            [ text "Hold left click for milliseconds" ]
        ; input'
            [ A.type' "text"
            ; A.id (F.Field.to_id Long_click_toggle_time)
            ; A.name (F.Field.to_id Long_click_toggle_time)
            ; A.value m.input.long_click_toggle_time
            ; E.onChange (fun v -> Filled_long_click_toggle_time v)
            ]
            []
        ]
    ]

let save_prefs prefs =
  Tea.Cmd.call (fun callbacks ->
      prefs |. Common.Storage.Local.set |. Promise.Js.toResult
      |. Promise.get (fun res -> !callbacks.enqueue (Saved_prefs res)))

let get_stored_prefs () =
  Tea.Cmd.call (fun callbacks ->
      Common.Storage_args.make_default ()
      |. Common.Storage.Local.get |. Promise.Js.toResult
      |. Promise.get (fun res -> !callbacks.enqueue (Got_stored_prefs res)))

let update m msg =
  match msg with
  | Got_stored_prefs res -> (
    match res with
    | Ok prefs ->
      let input =
        { F_args.long_click_toggle = prefs.longClickToggle
        ; long_click_toggle_time = prefs.longClickToggleTime |> string_of_int
        }
      in
      ({ F.state = Filling; input; problems = [] }, Tea.Cmd.none)
    | Error e -> ({ m with F.problems = [ F_args.Form_error e ] }, Tea.Cmd.none)
    )
  | Filled_long_click_toggle v ->
    let input = { m.F.input with long_click_toggle = v } in
    ( m |> F.update_form_with_input ~input
    , { longClickToggle = input.long_click_toggle
      ; longClickToggleTime = input.long_click_toggle_time |> int_of_string
      }
      |> save_prefs )
  | Filled_long_click_toggle_time v ->
    let input = { m.input with long_click_toggle_time = v } in
    ( m |> F.update_form_with_input ~input
    , { longClickToggle = input.long_click_toggle
      ; longClickToggleTime = input.long_click_toggle_time |> int_of_string
      }
      |> save_prefs )
  | Saved_prefs res -> (
    match res with
    | Ok () -> (m, Tea.Cmd.none)
    | Error e -> ({ m with F.problems = [ F_args.Form_error e ] }, Tea.Cmd.none)
    )

let init () =
  let default_prefs = Common.Storage_args.make_default () in
  let default_input =
    { F_args.long_click_toggle = default_prefs.longClickToggle
    ; long_click_toggle_time =
        default_prefs.longClickToggleTime |> string_of_int
    }
  in
  let model = F.init (Some default_input) in
  (model, get_stored_prefs ())

let main =
  Tea.App.standardProgram
    { init; subscriptions = (fun _ -> Tea.Sub.none); update; view }

let () =
  Ev.listen document
    (`DOMContentLoaded
      (fun _ ->
        Js.Console.log "DOMContentLoaded in prefs";
        match
          Dom_api.Document.get_optional_element_by_id Dom_api.document "root"
        with
        | Some root -> main root () |> ignore
        | None -> failwith "Prefs.ml: Root element not found"))
