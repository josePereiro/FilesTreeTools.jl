function walkup(f::Function, dir0::AbstractString;
        root = homedir(),
        onerr::Function = (path, err) -> rethrow(err),
    )

    root = abspath(root)
    dir0 = abspath(dir0)

    content = try; readdir(dir0)
        catch err; (onerr(dir0, err) === true) && return
    end

    # walk content
    path::String = ""
    subi = firstindex(content)
    sub1 = lastindex(content)
    while subi <= sub1
        try
            for _ in subi:sub1
                name = content[subi]
                subi += 1

                path = joinpath(dir0, name)
                (f(path) === true) && return
            end
        catch err;
            (onerr(path, err) === true) && return
        end
    end

    # base
    (dir0 == root) && return nothing
    
    # recursive
    walkup(f, dirname(dir0); root, onerr)
end