function _walkdown(f::Function, root::AbstractString; 
        keepout::Function, onerr::Function
    ) 
    content = readdir(root)
    for name in content
        
        path = joinpath(root, name)
        val = try; f(path)
            catch err; onerr(path, err) 
        end
        (val === true) && return val

        # recursive call
        if isdir(path)
            keepout(path) && continue
            _walkdown(f, path; keepout, onerr)
        end
    end
end

function _walkdown_th(f::Function, root::AbstractString;
        keepout::Function, onerr::Function,
        endsig::Ref{Bool}
    )

    endsig[] && return

    content = try; readdir(root)
        catch err; (onerr(root, err) === true) && (endsig[] = true; return)
    end

    # walk dir
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
                    @spawn _walkdown_th(f, $path; keepout, onerr, endsig)
                end
            end
        catch err
            (onerr(path, err) === true) && (endsig[] = true)
            endsig[] == true
        end
    end

end

"""
`walkdown_th(f, root; keepout = (dir) -> false, th = false)`

walkdown the file tree applying `f` to all the founded paths.
The return value of `f` is consider a break flag, so if it returns `true`
the walk if over.
`keepout` is a filter that disallows walks a dir if returns `true`.
This method do not waranty thread safetiness in any of it callbacks, 
`f` or `keepout`. You must do it for yourself.

"""
function walkdown(f::Function, root; 
        keepout::Function = (dir) -> false, 
        onerr::Function = (path, err) -> rethrow(err),
        th::Bool = false
    ) 
    th ? 
        _walkdown_th(f, root; keepout, onerr, endsig = Ref(false)) :
        _walkdown(f, root; keepout, onerr)
    
    return nothing
end



