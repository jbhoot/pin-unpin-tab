module type Storage_args = sig
  (* todo: 't can only be an object / record *)
  type t

  type 'v change =
    { old_value : 'v option [@mel.as "oldValue"]
    ; new_value : 'v option [@mel.as "newValue"]
    }

  type changes
end

module Browser = struct
  type tab_id

  type tab =
    { id : tab_id
    ; pinned : bool
    }

  module Browser_action = struct
    module On_clicked = struct
      (* TODO: Turn modifiers into a polymorphic type *)
      type on_click_data =
        { modifiers : string array (* e.g,. ["Shift"] *)
        ; button : int (* Mouse button code *)
        }

      external add_listener : (tab -> on_click_data -> unit) -> unit
        = "addListener"
        [@@mel.scope "browser", "browserAction", "onClicked"]

      external remove_listener : (tab -> on_click_data -> unit) -> unit
        = "removeListener"
        [@@mel.scope "browser", "browserAction", "onClicked"]
    end
  end

  module Runtime = struct
    (* todo: turn this into a functor *)

    type message_sender =
      { tab : tab
      ; id : string
      }

    external send_message_internally : 'msg -> ('resp_msg, string) Promise.Js.t
      = "sendMessage"
      [@@mel.scope "browser", "runtime"]

    module On_message = struct
      external add_listener :
        ('msg -> message_sender -> ('resp_msg, string) Promise.Js.t) -> unit
        = "addListener"
        [@@mel.scope "browser", "runtime", "onMessage"]

      external remove_listener :
        ('msg -> message_sender -> ('resp_msg, string) Promise.Js.t) -> unit
        = "removeListener"
        [@@mel.scope "browser", "runtime", "onMessage"]
    end
  end

  module Tabs = struct
    type update_properties = { pinned : bool }

    external update : tab_id -> update_properties -> (tab, string) Promise.Js.t
      = "update"
      [@@mel.scope "browser", "tabs"]
  end

  module Storage (Args : Storage_args) = struct
    type t = Args.t
    type changes = Args.changes

    type area_name =
      [ `sync
      | `local
      | `managed
      ]

    module Local = struct
      external get : t -> (t, string) Promise.Js.t = "get"
        [@@mel.scope "browser", "storage", "local"]

      external set : t -> (unit, string) Promise.Js.t = "set"
        [@@mel.scope "browser", "storage", "local"]
    end

    module On_changed = struct
      external add_listener : (Args.changes -> area_name -> unit) -> unit
        = "addListener"
        [@@mel.scope "browser", "storage", "onChanged"]

      external remove_listener : (Args.changes -> area_name -> unit) -> unit
        = "removeListener"
        [@@mel.scope "browser", "storage", "onChanged"]
    end
  end
end
