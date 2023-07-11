using AtomsIO
using Test
using AtomsBaseTesting

@testset "XSF system write / read" begin
    system = make_test_system().system
    mktempdir() do d
        outfile = joinpath(d, "output.xsf")
        save_system(XsfParser(), outfile, system)
        system2 = load_system(XsfParser(), outfile)
        test_approx_eq(system, system2; rtol=1e-6)
    end
end

@testset "XSF trajectory write/read" begin
    systems = [make_test_system().system for _ in 1:3]
    mktempdir() do d
        outfile = joinpath(d, "output.axsf")
        save_trajectory(XsfParser(), outfile, systems)
        newsystems = load_trajectory(XsfParser(), outfile)
        for (system, newsystem) in zip(systems, newsystems)
            test_approx_eq(system, newsystem; rtol=1e-6)
        end
        test_approx_eq(systems[end], load_system(XsfParser(), outfile);    rtol=1e-6)
        test_approx_eq(systems[2],   load_system(XsfParser(), outfile, 2); rtol=1e-6)
    end
end

@testset "ExtXYZ supports_parsing" begin
    import AtomsIO: supports_parsing
    prefix = "test"
    save = trajectory = true
    @test  supports_parsing(XsfParser(), prefix * ".xsf";    save, trajectory)
    @test  supports_parsing(XsfParser(), prefix * ".axsf";   save, trajectory)
    @test !supports_parsing(XsfParser(), prefix * ".bxsf";   save, trajectory)
    @test !supports_parsing(XsfParser(), prefix * ".cif";    save, trajectory)
end
