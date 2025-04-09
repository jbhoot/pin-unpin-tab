module Number = struct
  (* @val external makeInt: string => int = "Number" *)
  external make_int : string -> int = "Number"
end

module Int = struct
  let parse str =
    let regex = [%mel.re "/^[-+]?(\\d+)$/"] in
    match Js.Re.test ~str regex with
    | true -> (
      let v = Number.make_int str in
      match v |> Js.Int.toFloat |> Js.Float.isNaN with
      | true -> None
      | false -> Some v)
    | false -> None
end
