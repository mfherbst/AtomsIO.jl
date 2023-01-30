# AtomsIO

Standard package for reading and writing atomic structures represented as an
[AtomsBase](https://github.com/JuliaMolSim/AtomsBase.jl)-compatible data structure.
AtomsIO currently integrates with

  - [Chemfiles](https://github.com/chemfiles/Chemfiles.jl)
  - [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)
  - [ASEconvert](https://github.com/mfherbst/ASEconvert.jl) (respectively [ASE](https://wiki.fysik.dtu.dk/ase/))

and supports all file formats any of these packages support.
The best-matching backend for reading / writing is automatically chosen.

!!! note
    Unfortunately atomistic file formats are usually horribly underspecified
    and generally not all details are supported in all formats.
    Common examples are that some file formats are unable to store velocity
    information, others only work for non-periodic systems etc.
    Therefore even though we try to be careful, it frequently happens that
    some information is lost when writing a system to disk.
    An additional caveat is that the way how particular atomistic properties
    are mapped to individual data fields of a file format is not standardised
    amongst parser libraries. To recover a system as closely as possible,
    it is thus advisable to choose the same parser library for writing and
    reading a file. AtomsIO does this by default.

!!! tip
    For the reasons mentioned above the authors of AtomsIO recommend using
    extended XYZ format via the [`ExtxyzParser`](@ref) for long-term storage.
    This format and parser has a
    [well-documented specification](https://github.com/libAtoms/extxyz#extended-xyz-specifcation)
    and moreover leads to a human-readable plain-text file.
    If you have a different opinion we are happy to hear about it.
    Please open an issue for discussion.

## Usage example

```julia
using AtomsIO

# Load ASEconvert if you want to use it.
# This will load PythonCall and other ASEconvert dependencies.
# Not loading ASEconvert allows using AtomsIO without python.
using ASEconvert

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
