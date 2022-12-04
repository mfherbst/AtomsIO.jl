using Test

@testset "AtomsIO.jl" begin
    include("ase.jl")
    include("chemfiles.jl")
    include("comparison.jl")
end
