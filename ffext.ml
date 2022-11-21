module Browser = struct
  type tab_id

  type tab =
    { id : tab_id
    ; pinned : bool
    }

  module Browser_action = struct
    module On_clicked = struct
      external add_listener : (tab -> unit) -> unit = "addListener"
        [@@bs.val] [@@bs.scope "browser", "browserAction"]
    end
  end

  module Runtime = struct
    type message_sender =
      { tab : tab
      ; id : string
      }

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
end
