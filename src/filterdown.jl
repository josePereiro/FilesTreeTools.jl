function _filterdown(f, root; kwargs...)
    founds = String[]
    walkdown(root; kwargs..., thfrec = 0.0) do path
        f(path) && let
            push!(founds, path)
        end
        false
    end
    founds
end

function _filterdown_th(f, root; thfrec = 1.0, kwargs...)
    founds_pool = [String[] for _ in 1:nthreads()]
    walkdown(root; thfrec, kwargs...) do path 
        f(path) && push!(founds_pool[threadid()], path)
        false
    end
    vcat(founds_pool...)
end

function filterdown(f::Function, root; 
        thfrec::Float64 = 0.0, kwargs...
    )
    thfrec > 0.0 ?
        _filterdown_th(f, root; thfrec, kwargs...) :
        _filterdown(f, root; kwargs...)
end
