module Storage : sig
  module Local : sig
    type t
    type result = Ojs.t

    val get_all : t -> unit -> result Promise.t [@@js.call "get"]
    val get_one : t -> string -> result Promise.t [@@js.call "get"]
    val get_some : t -> string list -> result Promise.t [@@js.call "get"]
    val get_some_with_defaults : t -> 'a -> 'a Promise.t [@@js.call "get"]
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