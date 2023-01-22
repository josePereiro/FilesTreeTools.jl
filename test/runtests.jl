using FilesTreeTools
using Test
using Base.Threads

include("test_tool.jl")

@testset "FilesTreeTools.jl" begin
    # Write your tests here.
    @testset "up_down_tests.jl" begin
        include("up_down_tests.jl")
    end
end
