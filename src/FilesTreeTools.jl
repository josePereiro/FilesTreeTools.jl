module FilesTreeTools

using Base.Threads

# Write your package code here.
include("walkdown.jl")
include("filtertree.jl")

export walkdown, filtertree

end
