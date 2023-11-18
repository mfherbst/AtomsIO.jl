using AtomsIOPython
using Test
using AtomsBaseTesting

function make_ase_system(args...; drop_atprop=Symbol[], kwargs...)
    # ASE does not support vdw_radius and covalent_radius
    dropkeys = [:covalent_radius, :vdw_radius]
    make_test_system(args...; drop_atprop=append!(drop_atprop, dropkeys), kwargs...)
end

@testset "ASE parser has been added" begin
    @test AseParser() in AtomsIO.DEFAULT_PARSER_ORDER
end

@testset "ASE system write/read" begin
    # VDW radius and covalent radius not supported for ASE
    system = make_ase_system().system
    mktempdir() do d
        # Use extxyz, because it is the most lossless format of all.
        outfile = joinpath(d, "output.extxyz")
        save_system(AseParser(), outfile, system)
        newsystem = load_system(AseParser(), outfile)
        test_approx_eq(system, newsystem, rtol=1e-7)
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
            test_approx_eq(system, newsystem, rtol=1e-7)
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

@testset "ASE supports_parsing" begin
    import AtomsIO: supports_parsing
    mktempdir() do d
        prefix = joinpath(d, "test")

        @test  supports_parsing(AseParser(), prefix * ".pwi";  save=true,  trajectory=false)
        @test !supports_parsing(AseParser(), prefix * ".pwi";  save=true,  trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".cif";  save=true,  trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".cif";  save=true,  trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".traj"; save=true,  trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".traj"; save=true,  trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".xyz";  save=true,  trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".xyz";  save=true,  trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".xsf";  save=true,  trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".xsf";  save=true,  trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".vasp"; save=true,  trajectory=false)
        @test !supports_parsing(AseParser(), prefix * ".vasp"; save=true,  trajectory=true )

        for ext in (".pwi", ".cif", ".traj", ".xyz", ".xsf", ".vasp")
            save_system(AseParser(), prefix * ext, make_ase_system().system)
        end

        @test  supports_parsing(AseParser(), prefix * ".pwi";  save=false, trajectory=false)
        @test !supports_parsing(AseParser(), prefix * ".pwi";  save=false, trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".cif";  save=false, trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".cif";  save=false, trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".traj"; save=false, trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".traj"; save=false, trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".xyz";  save=false, trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".xyz";  save=false, trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".xsf";  save=false, trajectory=false)
        @test  supports_parsing(AseParser(), prefix * ".xsf";  save=false, trajectory=true )
        @test  supports_parsing(AseParser(), prefix * ".vasp"; save=false, trajectory=false)
        @test !supports_parsing(AseParser(), prefix * ".vasp"; save=false, trajectory=true )

        @test_logs (:warn, ) begin
            supports_parsing(AseParser(; guess=false), prefix * ".pwi"; save=false, trajectory=false)
        end
    end
end
