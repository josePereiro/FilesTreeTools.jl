module FilesTreeTools

    using Base.Threads
    using Base.Threads: @spawn

    # Write your package code here.
    include("tools.jl")
    include("walkdown.jl")
    include("filterdown.jl")
    include("walkup.jl")
    include("filterup.jl")

    export walkup, filterup
    export walkdown, filterdown

end
