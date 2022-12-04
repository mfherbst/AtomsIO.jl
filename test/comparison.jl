using AtomsIO
using Test
include("common.jl")

@testset "Test simple CIF files parse the same" begin
    mktempdir() do d
        outfile = "Mn3Si.cif"

        sys_ase  = load_system(AseParser(),       outfile)
        sys_cf   = load_system(ChemfilesParser(), outfile)
        sys_def  = load_system(outfile)

        ignore_atprop  = [:vdw_radius, :covalent_radius, :magnetic_moment]
        ignore_sysprop = [:spacegroup, :occupancy, :unit_cell]
        test_approx_eq(sys_ase, sys_cf; ignore_atprop, ignore_sysprop, atol=1e-5)
        test_approx_eq(sys_ase, sys_def; ignore_atprop, ignore_sysprop, atol=1e-5)
    end
end

@testset "Test simple XYZ files parse the same" begin
    drop_atprop  = [:covalent_radius, :vdw_radius, :atomic_mass, :charge, :velocity]
    drop_sysprop = [:extra_data]
    data = make_test_system(D; drop_atprop, drop_sysprop, cellmatrix=:lower_triangular)
    system = periodic_system(data.atoms, data.box; data.sysprop...)

    mktempdir() do d
        outfile = joinpath(d, "output.xyz")
        save_system(AseParser(), outfile, system)

        sys_ase  = load_system(AseParser(),       outfile)
        sys_cf   = load_system(ChemfilesParser(), outfile)
        sys_def  = load_system(outfile)

        ignore_atprop  = [:vdw_radius, :covalent_radius, :magnetic_moment]
        test_approx_eq(sys_ase, sys_cf;  ignore_atprop, atol=1e-6)
        test_approx_eq(sys_ase, sys_def; ignore_atprop, atol=1e-6)
    end
end
