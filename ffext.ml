module Browser = struct
  type tab_id

  type tab =
    { id : tab_id
    ; pinned : bool
    }

  module Browser_action = struct
    module On_clicked = struct
      external add_listener : (tab -> unit) -> unit = "addListener"
        [@@bs.val] [@@bs.scope "browser", "browserAction", "onClicked"]
    end
  end

  module Runtime = struct
    type message_sender =
      { tab : tab
      ; id : string
      }

    external send_message_internally : 'msg -> 'resp_msg Promise.t
      = "sendMessage"
      [@@bs.val] [@@bs.scope "browser", "runtime"]

    module On_message = struct
      type 'msg send_response = 'msg -> unit

      external add_listener_sync :
        ('msg -> message_sender -> 'resp_msg send_response -> unit) -> unit
        = "addListener"
        [@@bs.val] [@@bs.scope "browser", "runtime", "onMessage"]

      external add_listener_async :
        ('msg -> message_sender -> 'resp_msg Promise.t) -> unit = "addListener"
        [@@bs.val] [@@bs.scope "browser", "runtime", "onMessage"]
    end
  end

  module Tabs = struct
    type update_properties = { pinned : bool }

    external update : tab_id -> update_properties -> tab Promise.t = "update"
      [@@bs.val] [@@bs.scope "browser", "tabs"]
  end

  module Storage = struct
    type area_name =
      [ `sync
      | `local
      | `managed
      ]

    type ('o, 'n) storage_change =
      { (* todo: does old_value aotmatically translate to oldValue? *)
        old_value : 'o option
      ; new_value : 'n option
      }

    module Local = struct
      (* todo: 't can only be an object / record *)
      external get_all : unit -> 't Promise.t = "get"
        [@@bs.val] [@@bs.scope "browser", "storage", "local"]

      (* todo: 't can only be an object / record *)
      external get : 't -> 't Promise.t = "get"
        [@@bs.val] [@@bs.scope "browser", "storage", "local"]
    end

    module On_changed = struct
      external add_listener :
        (('o, 'n) storage_change Js.Dict.t -> area_name -> unit) -> unit
        = "addListener"
        [@@bs.val] [@@bs.scope "browser", "storage", "onChanged"]
    end
  end
end
