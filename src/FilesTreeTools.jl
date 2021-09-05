module FilesTreeTools

    using Base.Threads
    using Base.Threads: @spawn

    # Write your package code here.
    include("walkdown.jl")
    include("filtertree.jl")

    export walkdown, filtertree

end
