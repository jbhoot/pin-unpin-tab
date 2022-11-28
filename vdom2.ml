open Vdom

(* Element of { key: string; ns: string; tag: string; attributes: 'msg attribute
   list; children: 'msg vdom list; }

   let elt ?(ns = "") tag ?key ?(a = []) l = Element { key = (match key with
   None -> tag | Some k -> k); ns; tag; children = l; attributes = a; }

   let input ?key ?a l = elt "input" ?key ?a l let button ?(a = []) txt f =
   input [] ~a:(onclick (fun _ -> f) :: type_button :: value txt :: a) *)

module Form = struct
  let ele ?key ?a l = elt "form" ?key ?a l
end

module Label = struct
  let ele ?key ?(a = []) for_ l =
    elt "label" ?key ~a:(str_prop "for" for_ :: a) l
end

module Input = struct
  module Radio = struct
    let ele ?key ?(a = []) value =
      input [] ?key ~a:(type_ "radio" :: Vdom.value value :: a)
  end
end