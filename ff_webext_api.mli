module Storage : sig
  module Local : sig
    type t = private Ojs.t

    val get_all : t -> unit -> Ojs.t Promise.t [@@js.call "get"]
    val get_one : t -> string -> Ojs.t Promise.t [@@js.call "get"]
    val get_some : t -> string list -> Ojs.t Promise.t [@@js.call "get"]
    val get_some_with_defaults : t -> Ojs.t -> Ojs.t Promise.t [@@js.call "get"]
    val set : t -> Ojs.t -> unit Promise.t [@@js.call "set"]
  end

  type t = private Ojs.t

  val local : t -> Local.t [@@js.get]
end

module Browser : sig
  type t = private Ojs.t

  val storage : t -> Storage.t [@@js.get]
end

val browser : Browser.t [@@js.global]