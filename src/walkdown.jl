function _walkdown(f::Function, root::AbstractString; 
        keepout::Function, onerr::Function
    )

    content = try; readdir(root)
        catch err; (onerr(root, err) === true) && return
    end

    # walk dir
    path::String = ""
    subi = firstindex(content)
    sub1 = lastindex(content)
    while subi <= sub1
        try
            for _ in subi:sub1
                name = content[subi]
                subi += 1

                path = joinpath(root, name)
                (f(path) === true) && return

                if isdir(path)
                    keepout(path) && continue
                    _walkdown(f, path; keepout, onerr)
                end
            end
        catch err;
            (onerr(path, err) === true) && return
        end
    end
end

function _walkdown_th(f::Function, root::AbstractString;
        keepout::Function, onerr::Function,
        endsig::Ref{Bool}, thfrec::Float64
    )

    endsig[] && return
    
    content = try; readdir(root)
        catch err; (onerr(root, err) === true) && (endsig[] = true; return)
    end
    
    # walk dir
    allth = (thfrec >= 1.0)
    path::String = ""
    subi = firstindex(content)
    sub1 = lastindex(content)
    @sync while subi <= sub1
        try
            for _ in subi:sub1
                name = content[subi]
                subi += 1

                path = joinpath(root, name)
                (f(path) === true) && (endsig[] = true)
                endsig[] && return

                if isdir(path)
                    keepout(path) && continue
                    if allth || (rand() < thfrec)
                        @spawn _walkdown_th(f, $path; keepout, onerr, endsig, thfrec)
                    else
                       _walkdown_th(f, path; keepout, onerr, endsig, thfrec)
                    end
                end
            end
        catch err
            (onerr(path, err) === true) && (endsig[] = true)
            endsig[] == true
        end
    end

end

"""
`walkdown_th(f, root; onerr::Function, keepout::Function, thfrec::Float64)`

walkdown the file tree applying `f` to all the founded paths.
The return value of `f` is consider a break flag, so if it returns `true`
the walk if over.
`keepout` is a filter that disallows walks a dir if returns `true`.
`thfrec` = [0,1] determines the frecuency of @spawn threads.
That is, `thfrec > 0` makes the method multithreaded.
[NOTE] This method do not waranty thread safetiness in any of it callbacks, 
`f` or `keepout`. You must do it for yourself.

defaults:
    onerr = (path, err) -> (err isa InterruptException) ? rethrow(err) : nothing
    keepout = (dir) -> false
    thfrec = 0.0

"""
function walkdown(f::Function, root; 
        keepout::Function = _default_keepout, 
        onerr::Function = _default_onerr,
        thfrec::Float64 = 0.0
    ) 
    thfrec > 0.0 ? 
        _walkdown_th(f, root; keepout, onerr, endsig = Ref(false), thfrec) :
        _walkdown(f, root; keepout, onerr)
    
    return nothing
end



