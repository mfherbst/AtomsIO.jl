# AtomsIO

Standard package for reading and writing atomic structures represented as an
[AtomsBase](https://github.com/JuliaMolSim/AtomsBase.jl)-compatible data structure.
AtomsIO currently integrates with

  - [Chemfiles](https://github.com/chemfiles/Chemfiles.jl)
  - [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)
  - [ASEconvert](https://github.com/mfherbst/ASEconvert.jl) (respectively [ASE](https://wiki.fysik.dtu.dk/ase/))

and supports all file formats any of these packages support.
The best-matching backend for reading / writing is automatically chosen.

More details will follow soon.

## Usage example

```julia
using AtomsIO

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
