using Test

@testset "AtomsIO.jl" begin
    include("ase.jl")
    include("chemfiles.jl")
    include("extxyz.jl")
    include("comparison.jl")
end
