## ------------------------------------------------------------------------------------
function _filtertree(f, root; kwargs...)
    founds = String[]
    walkdown(root; kwargs..., th = false) do path
        f(path) && let
            push!(founds, path)
        end
        false
    end
    founds
end

function _filtertree_th(f, root; nths, kwargs...)
    founds_pool = [String[] for i in 1:nths]
    walkdown(root; nths, kwargs...) do path 
        f(path) &&  push!(founds_pool[threadid()], path)
        false
    end

    vcat(founds_pool...)
end

function filtertree(f::Function, root; 
        keepout = (dir) -> false, 
        onerr = (path, err) -> rethrow(onerr),
        nths = 1
    ) 

    return nths > 1 ?
        _filtertree_th(f, root; th, keepout, onerr, nths) :
        _filtertree(f, root; th, keepout, onerr)
end
