let empty_object = [%raw "{}"]

type pref_query =
  { longClickToggle : bool
  ; longClickToggleTime : int
  }

let prefs_query = { longClickToggle = true; longClickToggleTime = 600 }
