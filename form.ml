open Tea.Html2
module A = Tea.Html2.Attributes

module type Init_args = sig
  val id : string

  type field

  val field_id : field -> string

  type input
  type output

  type problem =
    | Field_error of field * string
    | Form_error of string

  val parse : input -> (output, problem list) result
  val init_input : input option -> input
end

module Make (Args : Init_args) = struct
  let id = Args.id

  type state =
    | Filling
    | Fixing
    | Submitting

  type input = Args.input
  type output = Args.output

  module Field = struct
    type t = Args.field

    let to_id = Args.field_id
    let to_error_description_id t = "Error-" ^ (t |> to_id)
    let to_normal_description_id t = "Desc-" ^ (t |> to_id)
    let to_attention_description_id t = "Attention-" ^ (t |> to_id)
  end

  type problem = Args.problem

  let parse = Args.parse

  type t =
    { state : state
    ; input : Args.input
    ; problems : problem list
    }

  let update_form_with_input t ~input =
    let problems =
      match input |> parse with
      | Ok _ -> []
      | Error problems -> problems
    in
    { t with input; problems }

  let field_has_errors t ~field =
    match t.state with
    | Filling -> false
    | Submitting -> false
    | Fixing ->
      t.problems
      |> List.exists (fun (p : problem) ->
             match p with
             | Field_error (invalid_field, _) -> field = invalid_field
             | Form_error _ -> false)

  let filter_field_errors (problems : problem list) ~field =
    problems
    |. Belt.List.reduce [] (fun acc problem ->
           match problem with
           | Field_error (problem_field, error) -> (
             match problem_field = field with
             | true -> error :: acc
             | false -> acc)
           | Form_error _ -> acc)

  let filter_form_errors (problems : problem list) =
    problems
    |. Belt.List.reduce [] (fun acc problem ->
           match problem with
           | Field_error _ -> acc
           | Form_error error -> error :: acc)

  let view_field_errors t ~field =
    match t.state with
    | Filling -> noNode
    | Submitting -> noNode
    | Fixing -> (
      match filter_field_errors t.problems ~field with
      | [] -> noNode
      | errors ->
        ul
          [ field |> Field.to_error_description_id |> A.id ]
          (errors |. Belt.List.map (fun e -> li [] [ e |> text ])))

  let view_form_errors t =
    match t.state with
    | Filling -> noNode
    | Submitting -> noNode
    | Fixing -> (
      match t.problems |> filter_form_errors with
      | [] -> noNode
      | errors ->
        ul
          [ "Error-" ^ id |> A.id ]
          (errors |. Belt.List.map (fun e -> li [] [ e |> text ])))

  let init input =
    { state = Filling; input = input |> Args.init_input; problems = [] }
end

let extract_problems result =
  match result with
  | Ok _ -> []
  | Error problems -> problems
