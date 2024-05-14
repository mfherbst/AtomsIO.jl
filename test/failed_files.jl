using LinearAlgebra

# Tests parsing files, where previously users reported problems
@testset "Failed files" begin
@testset "Empty XYZ" begin
    @static if VERSION < v"1.8"
        @test_throws ErrorException load_system("files/empty.xyz")
    else
        @test_throws "ExtXYZ returned no frames." load_system("files/empty.xyz")
    end
end

@testset "Zero atoms in XYZ" begin
    @static if VERSION < v"1.7"
        @test_throws TaskFailedException load_system("files/zero_atoms.xyz")
    elseif VERSION < v"1.8"
        @test_throws ErrorException load_system("files/zero_atoms.xyz")
    else
        @test_throws "ExtXYZ returned no frames. Check the passed file is a valid (ext)xyz file." load_system("files/zero_atoms.xyz")
    end
end

@testset "XYZ from Lammps" begin
    @static if VERSION < v"1.8"
        @test_throws ErrorException load_system("files/lammps.xyz")
    else
        @test_throws "ExtXYZ returned no frames." load_system("files/lammps.xyz")
    end
end

@testset "CIF Graphene P6/mmm" begin
    parsed = load_system("files/graphene.cif")
    reduced = reduce(hcat, bounding_box(parsed))

    @test maximum(abs, reduced - Diagonal(reduced)) < 1e-12u"Å"
    @test diag(reduced) ≈ [2.4595, 4.26, 30]u"Å"

    @test atomic_symbol(parsed) == [:C1, :C2, :C3, :C4]
    @test atomic_number(parsed) == [6, 6, 6, 6]
    @test parsed[:name] == "Graphene"
end
end
