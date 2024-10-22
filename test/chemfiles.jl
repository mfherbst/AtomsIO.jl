using AtomsIO
using Test
using AtomsBaseTesting
using Unitful
using UnitfulAtomic

function make_chemfiles_system(D=3; drop_atprop=Symbol[], infinite=false, kwargs...)
    dropkeys = [:covalent_radius, :vdw_radius]  # Cannot be mutated in Chemfiles
    data = make_test_system(D; drop_atprop=append!(drop_atprop, dropkeys),
                            extra_sysprop=(; extra_data=42.0), cellmatrix=:upper_triangular,
                            kwargs...)
    if infinite
        cell = IsolatedCell(3)
    else
        cell = PeriodicCell(; cell_vectors=data.box, periodicity=(true, true, true))
    end
    system = AtomsBase.FlexibleSystem(data.atoms, cell; data.sysprop...)
    merge(data, (; system))
end

@testset "Chemfiles system write / read" begin
    system = make_chemfiles_system(; drop_atprop=[:mass]).system
    mktempdir() do d
        outfile = joinpath(d, "output.cml")
        save_system(ChemfilesParser(), outfile, system)
        system2 = load_system(ChemfilesParser(), outfile)
        test_approx_eq(system, system2;
                       rtol=1e-6, ignore_atprop=[:covalent_radius, :vdw_radius])
    end
end

@testset "Chemfiles trajectory write/read" begin
    ignore_atprop = [:covalent_radius, :vdw_radius]
    systems = [make_chemfiles_system(; drop_atprop=[:mass]).system for _ in 1:3]
    mktempdir() do d
        outfile = joinpath(d, "output.cml")
        save_trajectory(ChemfilesParser(), outfile, systems)
        newsystems = load_trajectory(ChemfilesParser(), outfile)
        for (system, newsystem) in zip(systems, newsystems)
            test_approx_eq(system, newsystem; rtol=1e-6, ignore_atprop)
        end

        test_approx_eq(systems[end], load_system(ChemfilesParser(), outfile);
                       rtol=1e-6, ignore_atprop)
        test_approx_eq(systems[2], load_system(ChemfilesParser(), outfile, 2);
                       rtol=1e-6, ignore_atprop)
    end
end

@testset "Chemfiles supports_parsing" begin
    import AtomsIO: supports_parsing
    trajectory = true
    prefix = "test"

    @test !supports_parsing(ChemfilesParser(), prefix * ".trj"; save=true, trajectory)
    @test  supports_parsing(ChemfilesParser(), prefix * ".cif"; save=true, trajectory)
    @test  supports_parsing(ChemfilesParser(), prefix * ".sdf"; save=true, trajectory)

    @test  supports_parsing(ChemfilesParser(), prefix * ".trj"; save=false, trajectory)
    @test  supports_parsing(ChemfilesParser(), prefix * ".cif"; save=false, trajectory)
    @test  supports_parsing(ChemfilesParser(), prefix * ".sdf"; save=false, trajectory)
end
