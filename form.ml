open Tea.Html2
module A = Tea.Html2.Attributes

module type InitArgs = sig
  val id : string

  type field

  val fieldId : field -> string

  type input
  type output

  type problem =
    | FieldError of field * string
    | FormError of string

  val parse : input -> (output, problem list) result
  val initInput : input option -> input
end

module Make (Args : InitArgs) = struct
  let id = Args.id

  type state =
    | Filling
    | Fixing
    | Submitting

  type input = Args.input
  type output = Args.output

  module Field = struct
    type t = Args.field

    let toId = Args.fieldId
    let toErrorDescriptionId t = "Error-" ^ (t |> toId)
    let toNormalDescriptionId t = "Desc-" ^ (t |> toId)
    let toAttentionDescriptionId t = "Attention-" ^ (t |> toId)
  end

  type problem = Args.problem

  let parse = Args.parse

  type t =
    { state : state
    ; input : Args.input
    ; problems : problem list
    }

  let updateFormWithInput form input =
    let problems =
      match input |> parse with
      | Ok _ -> []
      | Error problems -> problems
    in
    { form with input; problems }

  let fieldHasErrors field t =
    match t.state with
    | Filling -> false
    | Submitting -> false
    | Fixing ->
      t.problems
      |> List.exists (fun p ->
             match p with
             | FieldError (invalidField, _) -> field = invalidField
             | FormError _ -> false)

  let filterFieldErrors field (problems : problem list) =
    problems
    |. Belt.List.reduce [] (fun acc problem ->
           match problem with
           | FieldError (problemField, error) -> (
             match problemField = field with
             | true -> error :: acc
             | false -> acc)
           | FormError _ -> acc)

  let filterFormErrors (problems : problem list) =
    problems
    |. Belt.List.reduce [] (fun acc problem ->
           match problem with
           | FieldError _ -> acc
           | FormError error -> error :: acc)

  let viewFieldErrors field form =
    match form.state with
    | Filling -> noNode
    | Submitting -> noNode
    | Fixing -> (
      match filterFieldErrors field form.problems with
      | [] -> noNode
      | errors ->
        ul
          [ field |> Field.toErrorDescriptionId |> A.id ]
          (errors |. Belt.List.map (fun e -> li [] [ e |> text ])))

  let viewFormErrors form =
    match form.state with
    | Filling -> noNode
    | Submitting -> noNode
    | Fixing -> (
      match form.problems |> filterFormErrors with
      | [] -> noNode
      | errors ->
        ul
          [ "Error-" ^ id |> A.id ]
          (errors |. Belt.List.map (fun e -> li [] [ e |> text ])))

  let init input =
    { state = Filling; input = input |> Args.initInput; problems = [] }
end

let resultToProblems result =
  match result with
  | Ok _ -> []
  | Error problems -> problems
