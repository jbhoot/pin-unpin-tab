module Console : sig
  type t = private Ojs.t

  val log : t -> Ojs.t -> unit [@@js.call "log"]
  val log_string : t -> string -> unit [@@js.call "log"]
end

val console : Console.t [@@js.global "console"]
