using Test
using AtomsIO
using AtomsBaseTesting

@testset "save / load / determine_parser" begin
    system = make_test_system().system

    @testset "Unsupported parser (VASP input)" begin
        @test_throws "Could not find a parser to load system" begin
            load_system("copper/POSCAR")
        end
        @test_throws "Could not find a parser to load trajectory" begin
            load_trajectory("copper/POSCAR")
        end
        @test_throws "Could not find a parser to save system" begin
            save_system("copper/POSCAR", system)
        end
        @test_throws "Could not find a parser to save trajectory" begin
            save_trajectory("copper/POSCAR", [system])
        end
    end
end
