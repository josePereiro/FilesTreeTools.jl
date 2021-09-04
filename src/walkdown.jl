function _walkdown(f, root; keepout, onerr) 
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
            val = _walkdown(f, path; keepout, onerr)
            (val === true) && return val 
        end
    end
end

function _walkdown_th(f, root; 
        keepout, nths, onerr
    ) 

    # init engine
    in_waiting_zone = trues(nths)
    dir_ch = Channel{String}(Inf)
    put!(dir_ch, root)

    @threads for _ in 1:nths
        thid = threadid()
        
        for curr_dir in dir_ch
            
            in_waiting_zone[thid] = false
            iput = false
            
            # read dir content
            content = try
                readdir(curr_dir)
            catch err
                (onerr(curr_dir, err) === true) && (close(dir_ch); return)
                continue
            end

            # walk dir
            path::String = ""
            subi = firstindex(content)
            sub1 = lastindex(content)
            while subi <= sub1
                try
                    for name in subi:sub1
                        name = content[subi]
                        path = joinpath(curr_dir, name)

                        (f(path) === true) && (close(dir_ch); return)
                        iput = isdir(path) && !keepout(path) && isopen(dir_ch)
                        iput && put!(dir_ch, path)
                        subi += 1
                    end
                catch err
                    (onerr(path, err) === true) && (close(dir_ch); return)
                    subi += 1
                end
            end

            # check zone
            in_waiting_zone[thid] = true
            !iput && isempty(dir_ch) && all(in_waiting_zone) && (close(dir_ch); return)
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
        nths::Int = 1
    ) 
    nths > 1 ?
        _walkdown_th(f, root; keepout, onerr, nths) :
        _walkdown(f, root; keepout, onerr)
    
    return nothing
end



