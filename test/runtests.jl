using Test
using Pkg

const GROUP = get(ENV, "GROUP", "Core")

if GROUP == "Core"
    @testset "AtomsIO.jl" begin
        include("ase.jl")
        include("chemfiles.jl")
        include("extxyz.jl")
        include("comparison.jl")
    end
else
    subpkg_path = joinpath(dirname(@__DIR__), "lib", GROUP)
    Pkg.develop(PackageSpec(path=subpkg_path))
    Pkg.test(PackageSpec(name=GROUP, path=subpkg_path))
end
