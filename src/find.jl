function findup(f::Function, dir0::AbstractString; kwargs...)
    found = nothing
    walkup(dir0; kwargs...) do path
        if f(path)
            found = path
            return true
        end
        return false
    end
    return found
end

function finddown(f::Function, dir0::AbstractString; kwargs...)
    found = nothing
    walkdown(dir0; kwargs...) do path
        if f(path)
            found = path
            return true
        end
        return false
    end
    return found
end