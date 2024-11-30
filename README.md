# AtomsIO

| **Documentation** | **Build status** | **License** |
|:----------------- |:---------------- |:----------- |
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mfherbst.github.io/AtomsIO.jl/dev) [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mfherbst.github.io/AtomsIO.jl/stable) | [![Build Status](https://github.com/mfherbst/AtomsIO.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mfherbst/AtomsIO.jl/actions/workflows/CI.yml?query=branch%3Amaster) [![Coverage][coverage-img]][coverage-url] | [![][license-img]][license-url]  |

[coverage-img]: https://codecov.io/gh/mfherbst/AtomsIO.jl/branch/master/graph/badge.svg
[coverage-url]: https://codecov.io/gh/mfherbst/AtomsIO.jl

[license-img]: https://img.shields.io/github/license/mfherbst/AtomsIO.jl.svg?maxAge=2592000
[license-url]: https://github.com/mfherbst/AtomsIO.jl/blob/master/LICENSE

Standard package for reading and writing atomic structures represented as an
[AtomsBase](https://github.com/JuliaMolSim/AtomsBase.jl)-compatible data structure.
AtomsIO currently integrates with

  - [Chemfiles](https://github.com/chemfiles/Chemfiles.jl)
  - [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)
  - [ASEconvert](https://github.com/mfherbst/ASEconvert.jl)
    (respectively [ASE](https://wiki.fysik.dtu.dk/ase/))

and supports all file formats any of these packages support.
Amongst others AtomsIO supports the following formats

  - [Crystallographic Information Framework](https://www.iucr.org/resources/cif) (CIF) files
  - [Quantum Espresso](https://www.quantum-espresso.org/Doc/INPUT_PW.html) / [ABINIT](https://docs.abinit.org/variables/) / [VASP](https://www.vasp.at/wiki/) input files
  - ASE / [Gromacs](http://manual.gromacs.org/archive/5.0.7/online/trj.html) / [LAMMPS](https://lammps.sandia.gov/doc/dump.html) / [Amber](http://ambermd.org/netcdf/nctraj.xhtml) trajectory files
  - [XYZ](https://openbabel.org/wiki/XYZ) and [extxyz](https://github.com/libAtoms/extxyz#extended-xyz-specification-and-parsing-tools) files

For more details see the [documentation](https://mfherbst.github.io/AtomsIO.jl/stable).

## File formats supported in earlier versions
These file formats were supported in earlier versions of AtomsIO, but are now
dropped as the implementing packages lack a maintainer and no longer function
with the most recent version of AtomsBase.

  - [XSF](http://www.xcrysden.org/doc/XSF.html) (XCrySDen) structure and
    trajectory files were supported using the
    [XCrySDenStructureFormat](https://github.com/azadoks/XCrySDenStructureFormat.jl)
    package.
    In case of interest,
    see the [draft PR](https://github.com/azadoks/XCrySDenStructureFormat.jl/pull/6),
    which can be completed to re-enable support.
