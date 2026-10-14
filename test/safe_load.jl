using Test
using AtomsIO
using AtomsBaseTesting

@testset "save / load / determine_parser" begin
    system = make_test_system().system
    poscar = joinpath(@__DIR__, "files", "copper", "POSCAR")
    @test isfile(poscar)

    @testset "Unsupported parser (VASP input)" begin
        @test_throws "Could not find a parser to load system" begin
            load_system(poscar)
        end
        @test_throws "Could not find a parser to load trajectory" begin
            load_trajectory(poscar)
        end
        mktempdir() do d
            # Save into a temporary directory to leave the test file untouched
            # should a parser for POSCAR ever become available.
            outfile = joinpath(d, "POSCAR")
            @test_throws "Could not find a parser to save system" begin
                save_system(outfile, system)
            end
            @test_throws "Could not find a parser to save trajectory" begin
                save_trajectory(outfile, [system])
            end
        end
    end

    @testset "Hint to load AtomsIOPython" begin
        # In the Core test group AtomsIOPython is never loaded,
        # so the error should point users to the python parsers.
        @test isempty(AtomsIO.atomsio_extra_parsers(AtomsIO.PythonParsers()))
        @test_throws "using AtomsIOPython" load_system(poscar)
    end
end
