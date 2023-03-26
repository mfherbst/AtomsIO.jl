using AtomsIOPython
using Test

@testset "AtomsIOPython.jl" begin
    include("ase.jl")
    include("comparison.jl")
end
