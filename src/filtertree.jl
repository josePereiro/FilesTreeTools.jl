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

function _filtertree_th(f, root; kwargs...)
    founds_pool = [String[] for _ in 1:nthreads()]
    walkdown(root; th = true, kwargs...) do path 
        f(path) && push!(founds_pool[threadid()], path)
        false
    end
    vcat(founds_pool...)
end

function filtertree(f::Function, root; 
        th::Bool = false, kwargs...
    )
    return th ?
        _filtertree_th(f, root; kwargs...) :
        _filtertree(f, root; kwargs...)
end
