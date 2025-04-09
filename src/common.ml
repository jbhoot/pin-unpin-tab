module Storage_args = struct
  (* WARN: Cannot rename longClickToggleTime and longClickToggle to retain
     backward compatibility and user preferences from previous versions *)
  type t =
    { longClickToggle : bool
    ; longClickToggleTime : int
    }

  type 'v change =
    { old_value : 'v option [@mel.as "oldValue"]
    ; new_value : 'v option [@mel.as "newValue"]
    }

  type changes =
    { longClickToggle : bool change
    ; longClickToggleTime : int change
    }

  let make_default () : t =
    { longClickToggle = true; longClickToggleTime = 800 }
end

module Storage = Ffext.Browser.Storage (Storage_args)
