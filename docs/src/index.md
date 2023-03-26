# AtomsIO

Standard package for reading and writing atomic structures represented as an
[AtomsBase](https://github.com/JuliaMolSim/AtomsBase.jl)-compatible data structure.
AtomsIO currently integrates with

  - [Chemfiles](https://github.com/chemfiles/Chemfiles.jl)
  - [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)
  - [ASEconvert](https://github.com/mfherbst/ASEconvert.jl)
    (respectively [ASE](https://wiki.fysik.dtu.dk/ase/))

and supports all file formats any of these packages support
(see their respective documentation). This includes

  - [Crystallographic Information Framework](https://www.iucr.org/resources/cif) (CIF) files
  - [Quantum Espresso](https://www.quantum-espresso.org/Doc/INPUT_PW.html) / [ABINIT](https://docs.abinit.org/variables/) / [VASP](https://www.vasp.at/wiki/) input files
  - ASE / [Gromacs](http://manual.gromacs.org/archive/5.0.7/online/trj.html) / [LAMMPS](https://lammps.sandia.gov/doc/dump.html) / [Amber](http://ambermd.org/netcdf/nctraj.xhtml) trajectory files
  - [XYZ](https://openbabel.org/wiki/XYZ) and [extxyz](https://github.com/libAtoms/extxyz#extended-xyz-specification-and-parsing-tools) files

For more details see [Saving and loading files](@ref) and [File Formats](@ref).

!!! note Python-based parsers
    Reading / writing some formats relies on parser libraries from third-party Python packages.
    To avoid introducing Python dependencies in all packages employing `AtomsIO` the additional
    package `AtomsIOPython` needs to be loaded to make these parsers available.
    See [File Formats](@ref) for more details.

## Usage example

```julia
using AtomsIO        # Enables only Julia-based parsers
using AtomsIOPython  # Enable python-based parsers as well

# Load system from a cif file ... by default uses ASE.
# Returns an AtomsBase-compatible system.
system = load_system("Si.cif")

# The system can now be used with any package supporting AtomsBase,
# e.g. display unit cell, positions and chemical formula ...
@show bounding_box(system)
@show position(system)
@show chemical_formula(system)

# ... or do a DFT calculation using DFTK.
using DFTK
model  = model_LDA(system)
basis  = PlaneWaveBasis(model; Ecut=15, kgrid=(3, 3, 3))
scfres = self_consistent_field(basis);

# We could also load a whole trajectory (as a list of systems):
trajectory = load_trajectory("mdrun.traj")

# ... or only the 6-th structure:
last_system = load_system("mdrun.traj", 6)
```
