using AtomsIO
using Test
include("common.jl")

@testset "Conversion to ExtXYZ (velocity)" begin
    import ExtXYZ
    system, atoms, atprop, sysprop, box, bcs = make_test_system()
    atoms = AtomsIO.convert_extxyz(system)

    cell = zeros(3, 3)
    for i in 1:3
        cell[i, :] = ustrip.(u"Å", box[i])
    end

    @assert bcs == [Periodic(), Periodic(), DirichletZero()]
    @test atoms["pbc"]     == [true, true, false]
    @test atoms["N_atoms"] == 5
    @test atoms["cell"]    == cell

    info = atoms["info"]
    @test sort(collect(keys(info))) == ["charge", "extra_data", "multiplicity"]
    @test info["charge"]       == ustrip.(u"e_au", sysprop.charge)
    @test info["extra_data"]   == sysprop.extra_data
    @test info["multiplicity"] == sysprop.multiplicity

    arrays = atoms["arrays"]
    @test arrays["Z"]          == atprop.atomic_number
    @test arrays["species"]    == string.(atprop.atomic_symbol)
    @test arrays["mass"]       == ustrip.(u"u",   atprop.atomic_mass)
    @test arrays["pos"]        ≈  ustrip.(u"Å",   hcat(atprop.position...)) atol=1e-10
    @test arrays["velocities"] ≈  ustrip.(u"Å/s", hcat(atprop.velocity...)) atol=1e-10

    expected_atkeys = ["Z", "charge", "covalent_radius", "magnetic_moment",
                       "mass", "pos", "species", "vdw_radius", "velocities"]
    @test sort(collect(keys(arrays))) == expected_atkeys
    @test arrays["magnetic_moment"] == atprop.magnetic_moment
    @test arrays["vdw_radius"]      == ustrip.(u"Å", atprop.vdw_radius)
    @test arrays["covalent_radius"] == ustrip.(u"Å", atprop.covalent_radius)
    @test arrays["charge"]          == ustrip.(u"e_au", atprop.charge)
end


@testset "Conversion to ExtXYZ (no velocity)" begin
    import ExtXYZ
    system = make_test_system(; drop_atprop=[:velocity]).system
    atoms  = AtomsIO.convert_extxyz(system)
    @test iszero(atoms["arrays"]["velocities"])
end

@testset "Warning about setting invalid data" begin
    import ExtXYZ
    system = make_test_system(; extra_sysprop=(md=3u"u", symboldata=:abc),
                                extra_atprop=(massdata=3ones(5)u"u",
                                              atomic_symbol=[:D, :H, :C, :N, :He])).system
    atoms = @test_logs((:warn, r"Unitful quantity massdata is not yet"),
                       (:warn, r"Writing quantities of type Symbol"),
                       (:warn, r"Unitful quantity md is not yet"),
                       (:warn, r"Mismatch between atomic numbers and atomic symbols"),
                       match_mode=:any, AtomsIO.convert_extxyz(system))

    @test atoms["arrays"]["species"] == ["H", "H", "C", "N", "He"]
    @test atoms["arrays"]["Z"]       == [1, 1, 6, 7, 2]
end

@testset "Conversion AtomsBase -> ExtXYZ -> AtomsBase" begin
    system    = make_test_system().system
    atoms     = AtomsIO.convert_extxyz(system)
    newsystem = AtomsIO.parse_extxyz(atoms)
    test_approx_eq(system, newsystem; atol=1e-12)
end

@testset "ExtXYZ system write / read" begin
    system = make_test_system().system
    mktempdir() do d
        outfile = joinpath(d, "output.xyz")
        save_system(ExtxyzParser(), outfile, system)
        system2 = load_system(ExtxyzParser(), outfile)
        test_approx_eq(system, system2; atol=1e-7)
    end
end

@testset "ExtXYZ trajectory write/read" begin
    systems = [make_test_system().system for _ in 1:3]
    mktempdir() do d
        outfile = joinpath(d, "output.extxyz")
        save_trajectory(ExtxyzParser(), outfile, systems)
        newsystems = load_trajectory(ExtxyzParser(), outfile)
        for (system, newsystem) in zip(systems, newsystems)
            test_approx_eq(system, newsystem; atol=1e-7)
        end
        test_approx_eq(systems[end], load_system(ExtxyzParser(), outfile);    atol=1e-7)
        test_approx_eq(systems[2],   load_system(ExtxyzParser(), outfile, 2); atol=1e-7)
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
