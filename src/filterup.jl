function filterup(f, dir0; kwargs...)
    founds = String[]
    walkup(dir0; kwargs...) do path
        f(path) && push!(founds, path)
        false
    end
    founds
end