using FilesTreeTools
using Test
using Base.Threads

include("test_tool.jl")

@testset "FilesTreeTools.jl" begin
    # Write your tests here.
    @testset "test_walkdown.jl" begin
        include("test_walkdown.jl")
    end
end
