module Query : sig
  val make : longClickToggle:bool -> longClickToggleTime:int -> Ojs.t
    [@@js.builder]
end
