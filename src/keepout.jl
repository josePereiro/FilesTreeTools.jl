_default_keepout(dir) = false
_select_keepout(keepout::Function) = keepout
_select_keepout(keepout::Vector{<:AbstractString}) = (path) -> begin
    path = basename(path)
    for name in keepout
        path == name && return true
    end
    return false
end
_select_keepout(patts::Vector{Regex}) = (path) -> begin
    for reg in patts
        m = match(reg, path)
        isnothing(m) || return true
    end
    return false
end
