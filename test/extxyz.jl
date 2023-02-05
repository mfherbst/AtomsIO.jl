using AtomsIO
using Test
include("common.jl")

@testset "ExtXYZ system write / read" begin
    system = make_test_system().system
    mktempdir() do d
        outfile = joinpath(d, "output.xyz")
        save_system(ExtxyzParser(), outfile, system)
        system2 = load_system(ExtxyzParser(), outfile)
        test_approx_eq(system, system2; rtol=1e-6)
    end
end

@testset "ExtXYZ trajectory write/read" begin
    systems = [make_test_system().system for _ in 1:3]
    mktempdir() do d
        outfile = joinpath(d, "output.extxyz")
        save_trajectory(ExtxyzParser(), outfile, systems)
        newsystems = load_trajectory(ExtxyzParser(), outfile)
        for (system, newsystem) in zip(systems, newsystems)
            test_approx_eq(system, newsystem; rtol=1e-6)
        end
        test_approx_eq(systems[end], load_system(ExtxyzParser(), outfile);    rtol=1e-6)
        test_approx_eq(systems[2],   load_system(ExtxyzParser(), outfile, 2); rtol=1e-6)
    end
end

@testset "ExtXYZ supports_parsing" begin
    import AtomsIO: supports_parsing
    prefix = "test"
    save = trajectory = true
    @test  supports_parsing(ExtxyzParser(), prefix * ".xyz";    save, trajectory)
    @test  supports_parsing(ExtxyzParser(), prefix * ".extxyz"; save, trajectory)
    @test !supports_parsing(ExtxyzParser(), prefix * ".cif";    save, trajectory)
end
