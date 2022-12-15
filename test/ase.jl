using AtomsIO
using Test
include("common.jl")

function make_ase_system(args...; drop_atprop=Symbol[], kwargs...)
    # ASE does not support vdw_radius and covalent_radius
    dropkeys = [:covalent_radius, :vdw_radius]
    make_test_system(args...; drop_atprop=append!(drop_atprop, dropkeys), kwargs...)
end

@testset "ASE system write/read" begin
    # VDW radius and covalent radius not supported for ASE
    system = make_ase_system().system
    mktempdir() do d
        # Use extxyz, because it is the most lossless format of all.
        outfile = joinpath(d, "output.extxyz")
        save_system(AseParser(), outfile, system)
        newsystem = load_system(AseParser(), outfile)
        test_approx_eq(system, newsystem, atol=1e-6)
    end
end

@testset "ASE trajectory write/read" begin
    systems = [system = make_ase_system().system for _ in 1:3]
    mktempdir() do d
        # Use extxyz, because it is the most lossless format of all.
        outfile = joinpath(d, "output.traj")
        save_trajectory(AseParser(), outfile, systems)
        newsystems = load_trajectory(AseParser(), outfile)
        for (system, newsystem) in zip(systems, newsystems)
            test_approx_eq(system, newsystem, atol=1e-6)
        end

        test_approx_eq(systems[end], load_system(AseParser(), outfile))
        test_approx_eq(systems[2],   load_system(AseParser(), outfile, 2))
    end
end

@testset "ASE force format" begin
    system = make_ase_system().system
    mktempdir() do d
        file1 = joinpath(d, "output.extxyz")
        file2 = joinpath(d, "output.cif")
        save_system(AseParser(), file1, system)
        save_system(AseParser(), file2, system, format="extxyz")

        @test readlines(file1) == readlines(file2)
    end
end
