using Test
using Pkg

const GROUP = get(ENV, "GROUP", "Core")
const GROUP_COVERAGE = !isempty(get(ENV, "GROUP_COVERAGE", ""))

if GROUP == "Core"
    @testset "AtomsIO.jl" begin
        include("chemfiles.jl")
        include("extxyz.jl")
        # For the comparison tests (also between Chemfiles and ExtXYZ and other
        # non-python libraries) see the AtomsIOPython subproject
    end
else
    subpkg_path = joinpath(dirname(@__DIR__), "lib", GROUP)
    Pkg.develop(PackageSpec(path=subpkg_path))
    Pkg.test(PackageSpec(name=GROUP, path=subpkg_path), coverage=GROUP_COVERAGE)
end
