# File Formats

This page provides an overview of parsing libraries interfaced from `AtomsIO`
and an (incomplete) list of file formats they support. The parsing libraries
are listed in order of preference, i.e. the order in which
[`AtomsIO.load_system`](@ref), [`AtomsIO.save_system`](@ref),
[`AtomsIO.load_trajectory`](@ref) and [`AtomsIO.save_trajectory`](@ref)
will attempt the parsing libraries
until one flags that it supports parsing/writing such a format.
If a file format is thus listed in combination with multiple parsers,
the above methods will only ever consult the *first* of the parser libraries.
Note that one can always overwrite the automatic `AtomsIO` selection by providing
the parser library explicitly as first argument.

AtomsIO also features an integration with a number of python libraries
(such as [ASE](https://wiki.fysik.dtu.dk/ase/))
to support parsing a wide range of atomic structure files.
These python-based are not enabled by default to avoid introducing Python dependencies
for down-stream code when this can be avoided. Python-dependent code paths can be
activated by a simple `using AtomsIOPython` before calling `load_system` or `save_system`
or similar. This should automatically install all required python dependencies.

!!! note
    Unfortunately atomistic file formats are usually horribly underspecified
    and generally not all details are supported in all formats.
    Common examples are that some file formats are unable to store velocity
    information, others only work for non-periodic systems etc.
    Therefore even though we try to be careful in AtomsIO, it frequently happens that
    some information is lost when writing a system to disk.
    An additional caveat is that the way how particular atomistic properties
    are mapped to individual data fields of a file format is not standardised
    amongst parser libraries. To recover a system as closely as possible,
    it is thus advisable to choose the same parser library for writing and
    reading a file.

!!! tip
    For the reasons mentioned above a good long-term storage format
    (in the eyes of the AtomsIO authors) is the extended XYZ format
    via the [`AtomsIO.ExtxyzParser`](@ref).
    This format and parser has a
    [well-documented specification](https://github.com/libAtoms/extxyz#extended-xyz-specifcation)
    and moreover leads to a human-readable plain-text file.

The following list all currently available parsers, in the order they are tried
(top to bottom):

```@docs
AtomsIO.ExtxyzParser
AtomsIO.ChemfilesParser
AtomsIOPython.AseParser
```
