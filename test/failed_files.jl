using Test
using AtomsIO
using Unitful
using LinearAlgebra

# Tests parsing files, where previously users reported problems
@testset "Failed files" begin
@testset "Empty XYZ" begin
    @test_throws "ExtXYZ returned no frames." load_system("files/empty.xyz")
end

@testset "XYZ from Lammps" begin
    @test_throws "ExtXYZ returned no frames." load_system("files/lammps.xyz")
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
