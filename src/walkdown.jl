function _walkdown(f::Function, root::AbstractString; 
        keepout::Function, onerr::Function
    )

    subpaths = try; readdir(root; join = true)
        catch err; 
            flag = onerr(path, err)
            (flag === true) && return flag
    end

    # walk dir
    path::String = ""
    subi = firstindex(subpaths)
    sub1 = lastindex(subpaths)
    while subi <= sub1
        try
            for _ in subi:sub1
                path = subpaths[subi]
                subi += 1

                flag = f(path)
                if (flag === true) 
                    return flag
                end

                if isdir(path)
                    keepout(path) && continue
                    flag = _walkdown(f, path; keepout, onerr)
                    (flag === true) && return flag
                end
            end
        catch err;
            flag = onerr(path, err)
            (flag === true) && return flag
        end
    end # whiles
end

function _walkdown_th(f::Function, root::AbstractString;
        keepout::Function, onerr::Function,
        endsig::Ref{Bool}, thfrec::Float64
    )

    endsig[] && return endsig[]
    
    subpaths = try; readdir(root; join = true)
        catch err; 
            flag = onerr(root, err) 
            (flag === true) && (endsig[] = flag; return flag)
    end
    
    # walk dir
    allth = (thfrec >= 1.0)
    path::String = ""
    subi = firstindex(subpaths)
    sub1 = lastindex(subpaths)
    @sync while subi <= sub1
        try
            for _ in subi:sub1
                path = subpaths[subi]
                subi += 1

                endsig[] && return endsig[]
                flag = f(path)
                (flag === true) && (endsig[] = flag)
                endsig[] && return endsig[]

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
            flag = onerr(path, err)
            (flag === true) && (endsig[] = flag)
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



