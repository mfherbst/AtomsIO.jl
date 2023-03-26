using AtomsIOPython
using Test
include("common.jl")

@testset "Test simple CIF files parse the same" begin
    mktempdir() do d
        outfile = joinpath(@__DIR__, "Mn3Si.cif")

        sys_ase  = load_system(AseParser(),       outfile)
        sys_cf   = load_system(ChemfilesParser(), outfile)
        sys_def  = load_system(outfile)

        ignore_atprop  = [:vdw_radius, :covalent_radius, :magnetic_moment]
        ignore_sysprop = [:spacegroup, :occupancy, :unit_cell]
        test_approx_eq(sys_ase, sys_cf;
                       ignore_atprop, ignore_sysprop, rtol=1e-5, common_only=true)
        test_approx_eq(sys_ase, sys_def;
                       ignore_atprop, ignore_sysprop, rtol=1e-5, common_only=true)
    end
end

@testset "Test structures from simple XYZ files parse the same" begin
    drop_atprop  = [:covalent_radius, :vdw_radius, :velocity, :charge, :atomic_mass]
    drop_sysprop = [:extra_data]
    data = make_test_system(; drop_atprop, drop_sysprop, cellmatrix=:lower_triangular)
    system = periodic_system(data.atoms, data.box; data.sysprop...)

    mktempdir() do d
        outfile = joinpath(d, "output.xyz")
        save_system(ExtxyzParser(), outfile, system)

        sys_ase  = load_system(AseParser(),       outfile)
        sys_cf   = load_system(ChemfilesParser(), outfile)
        sys_xyz  = load_system(ExtxyzParser(),    outfile)
        sys_def  = load_system(outfile)

        ignore_atprop  = [:magnetic_moment, :charge, :vdw_radius, :covalent_radius]
        test_approx_eq(sys_ase, sys_cf;  ignore_atprop, rtol=1e-5, common_only=true)
        test_approx_eq(sys_ase, sys_xyz; ignore_atprop, rtol=1e-5, common_only=true)
        test_approx_eq(sys_ase, sys_def; ignore_atprop, rtol=1e-5, common_only=true)
    end
end
