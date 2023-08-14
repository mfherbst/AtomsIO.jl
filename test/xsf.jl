using AtomsIO
using Test
using AtomsBaseTesting
using Unitful
using UnitfulAtomic


function make_xsf_system(D=3; drop_atprop=Symbol[], drop_sysprop=Symbol[], kwargs...)
    @assert D == 3  # Only 3D systems are supported
    n_atoms = 5     # Copied from AtomsBaseTesting.make_test_system, used for making forces
    xsf_drop_atprop = [:velocity, :charge, :atomic_mass, :vdw_radius, :covalent_radius,
                       :magnetic_moment]
    xsf_drop_sysprop = [:extra_data, :charge, :multiplicity]
    force = [randn(3)u"Eh_au/Å" for _ in 1:n_atoms]
    make_test_system(D; drop_atprop=append!(drop_atprop, xsf_drop_atprop),
                     drop_sysprop=append!(drop_sysprop, xsf_drop_sysprop),
                     extra_sysprop=(; ), extra_atprop=(; force), kwargs...)
end

@testset "XSF system write / read" begin
    XsfParser = AtomsIO.XcrysdenstructureformatParser

    system = make_xsf_system().system
    mktempdir() do d
        outfile = joinpath(d, "output.xsf")
        save_system(XsfParser(), outfile, system)
        system2 = load_system(XsfParser(), outfile)
        test_approx_eq(system, system2; rtol=1e-6)
    end
end

@testset "XSF trajectory write/read" begin
    XsfParser = AtomsIO.XcrysdenstructureformatParser

    systems = [make_xsf_system().system for _ in 1:3]
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
    XsfParser = AtomsIO.XcrysdenstructureformatParser

    prefix = "test"
    save = trajectory = true
    @test  supports_parsing(XsfParser(), prefix * ".xsf";  save, trajectory)
    @test  supports_parsing(XsfParser(), prefix * ".axsf"; save, trajectory)
    @test !supports_parsing(XsfParser(), prefix * ".bxsf"; save, trajectory)
    @test !supports_parsing(XsfParser(), prefix * ".cif";  save, trajectory)
end
