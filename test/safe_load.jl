@testset "save / load / determine_parser" begin
    system = make_test_system().system

    @testset "Unsupported parser (VASP input)" begin
        @static if VERSION < v"1.8"
            @test_throws ErrorException load_system("copper/POSCAR")
            @test_throws ErrorException load_trajectory("copper/POSCAR")

            @test_throws ErrorException save_system("copper/POSCAR", system)
            @test_throws ErrorException save_trajectory("copper/POSCAR", [system])
        else
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
end
