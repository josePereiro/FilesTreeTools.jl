_default_onerr(path, err) = (err isa InterruptException) ? rethrow(err) : nothing
_default_keepout(dir) = false