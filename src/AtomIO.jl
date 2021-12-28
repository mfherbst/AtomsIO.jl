module AtomIO
using AtomsBase
using PyCall
using Unitful

export load_system, save_system

function load_system(file::AbstractString)
    ase = pyimport_e("ase")
    ispynull(ase) && error("Install ASE to load data from exteral files")
    ase_atoms = pyimport("ase.io").read(file)

    T = Float64
    cell_julia = convert(Array, ase_atoms.cell)  # Array of arrays
    box = [[T(cell_julia[j][i]) * u"Å" for i = 1:3] for j = 1:3]

    atoms = map(ase_atoms) do at
        atnum = convert(Int, at.number)
        Atom(atnum, at.position * u"Å"; magnetic_moment=at.magmom)
    end
    bcs = [p ? Periodic() : DirichletZero() for p in ase_atoms.pbc]
    atomic_system(atoms, box, bcs)
end

function save_system(filename::AbstractString, system::AbstractSystem)
    error("Not yet implemented.")
end

end
