abstract type AbstractParser end


"""
Parse or write file using [Chemfiles](https://github.com/chemfiles/Chemfiles.jl).

Supported formats:
  - [CIF](https://www.iucr.org/resources/cif) files
  - [Gromacs](http://manual.gromacs.org/archive/5.0.7/online/trj.html) / [LAMMPS](https://lammps.sandia.gov/doc/dump.html) / [Amber](http://ambermd.org/netcdf/nctraj.xhtml) trajectory files
"""
struct ChemfilesParser <: AbstractParser end

"""
Parse or write file using [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)

Supported formats:
  - [XYZ](https://openbabel.org/wiki/XYZ) and [extxyz](https://github.com/libAtoms/extxyz#extended-xyz-specification-and-parsing-tools) files
"""
struct ExtxyzParser <: AbstractParser end


"""
Parse or write file using [XCrySDenStructureFormat](https://github.com/azadoks/XCrySDenStructureFormat.jl).

Supported formats:
  - [XSF](http://www.xcrysden.org/doc/XSF.html) and [AXSF](http://www.xcrysden.org/doc/XSF.html)
    atomic structure files. These are the files typically used by the
    [XCrySDen](http://www.xcrysden.org/) visualisation program.
"""
struct XcrysdenstructureformatParser <: AbstractParser end

supports_parsing(::AbstractParser, file; save, trajectory) = false
