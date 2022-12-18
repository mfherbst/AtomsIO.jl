using AtomsIO
using Test
include("common.jl")

function make_chemfiles_system(D=3; drop_atprop=Symbol[], infinite=false, kwargs...)
    dropkeys = [:covalent_radius, :vdw_radius]  # Cannot be mutated in Chemfiles
    data = make_test_system(D; drop_atprop=append!(drop_atprop, dropkeys),
                            extra_sysprop=(; extra_data=42.0), cellmatrix=:lower_triangular,
                            kwargs...)
    if infinite
        system = isolated_system(data.atoms; data.sysprop...)
    else
        system = periodic_system(data.atoms, data.box; data.sysprop...)
    end
    merge(data, (; system))
end

@testset "Conversion to Chemfiles (periodic, velocity)" begin
    import Chemfiles

    system, atoms, atprop, sysprop, box, bcs = make_chemfiles_system(; infinite=false)
    frame = AtomsIO.convert_chemfiles(system)

    D = 3
    cell = Chemfiles.matrix(Chemfiles.UnitCell(frame))
    for i in 1:D
        @test cell[i, :] ≈ ustrip.(u"Å", box[i]) atol=1e-12
    end
    @test Chemfiles.shape(Chemfiles.UnitCell(frame)) in (Chemfiles.Triclinic,
                                                         Chemfiles.Orthorhombic)
    for (i, atom) in enumerate(frame)
        @test(Chemfiles.positions(frame)[:, i]
              ≈ ustrip.(u"Å", atprop.position[i]), atol=1e-12)
        @test(Chemfiles.velocities(frame)[:, i]
              ≈ ustrip.(u"Å/s", atprop.velocity[i]), atol=1e-12)

        @test Chemfiles.name(atom)            == string(atprop.atomic_symbol[i])
        @test Chemfiles.atomic_number(atom)   == atprop.atomic_number[i]
        @test Chemfiles.mass(atom)            == ustrip(u"u", atprop.atomic_mass[i])
        @test Chemfiles.charge(atom)          == ustrip(u"e_au", atprop.charge[i])
        @test Chemfiles.list_properties(atom) == ["magnetic_moment"]
        @test Chemfiles.property(atom, "magnetic_moment") == atprop.magnetic_moment[i]

        if atprop.atomic_number[i] == 1
            @test Chemfiles.vdw_radius(atom)      == 1.2
            @test Chemfiles.covalent_radius(atom) == 0.37
        end
    end

    @test Chemfiles.list_properties(frame)    == ["charge", "extra_data", "multiplicity"]
    @test Chemfiles.property(frame, "charge") == ustrip(u"e_au", sysprop.charge)
    @test Chemfiles.property(frame, "extra_data") == sysprop.extra_data
    @test Chemfiles.property(frame, "multiplicity") == sysprop.multiplicity
end

@testset "Conversion to Chemfiles (infinite, no velocity)" begin
    import Chemfiles
    system = make_chemfiles_system(; infinite=true, drop_atprop=[:velocity]).system
    frame = AtomsIO.convert_chemfiles(system)
    @test Chemfiles.shape(Chemfiles.UnitCell(frame)) == Chemfiles.Infinite
    @test iszero(Chemfiles.velocities(frame))
end

@testset "Warning about setting invalid data" begin
    import Chemfiles
    system, atoms, atprop, sysprop, box, bcs = make_test_system()
    frame  = @test_logs((:warn, r"Atom vdw_radius in Chemfiles cannot be mutated"),
                        (:warn, r"Atom covalent_radius in Chemfiles cannot be mutated"),
                        (:warn, r"Ignoring unsupported property type \(Int64\).*extra_data"),
                        (:warn, r"Ignoring specified boundary conditions:"),
                        match_mode=:any, AtomsIO.convert_chemfiles(system))

    D = 3
    cell = Chemfiles.matrix(Chemfiles.UnitCell(frame))
    for i in 1:D
        @test cell[i, :] ≈ ustrip.(u"Å", box[i]) atol=1e-12
    end
    @test Chemfiles.shape(Chemfiles.UnitCell(frame)) in (Chemfiles.Triclinic,
                                                         Chemfiles.Orthorhombic)
end

@testset "Conversion AtomsBase -> Chemfiles -> AtomsBase" begin
    system = make_chemfiles_system().system
    frame  = AtomsIO.convert_chemfiles(system)
    newsystem = AtomsIO.parse_chemfiles(frame)
    test_approx_eq(system, newsystem;
                   atol=1e-12, ignore_atprop=[:covalent_radius, :vdw_radius])
end

@testset "Chemfiles system write / read" begin
    system = make_chemfiles_system(; drop_atprop=[:atomic_mass]).system
    mktempdir() do d
        outfile = joinpath(d, "output.cml")
        save_system(ChemfilesParser(), outfile, system)
        system2 = load_system(ChemfilesParser(), outfile)
        test_approx_eq(system, system2;
                       atol=1e-6, ignore_atprop=[:covalent_radius, :vdw_radius])
    end
end

@testset "Chemfiles trajectory write/read" begin
    ignore_atprop = [:covalent_radius, :vdw_radius]
    systems = [make_chemfiles_system(; drop_atprop=[:atomic_mass]).system for _ in 1:3]
    mktempdir() do d
        outfile = joinpath(d, "output.cml")
        save_trajectory(ChemfilesParser(), outfile, systems)
        newsystems = load_trajectory(ChemfilesParser(), outfile)
        for (system, newsystem) in zip(systems, newsystems)
            test_approx_eq(system, newsystem; atol=1e-6, ignore_atprop)
        end

        test_approx_eq(systems[end], load_system(ChemfilesParser(), outfile);
                       atol=1e-6, ignore_atprop)
        test_approx_eq(systems[2],   load_system(ChemfilesParser(), outfile, 2);
                       atol=1e-6, ignore_atprop)
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
