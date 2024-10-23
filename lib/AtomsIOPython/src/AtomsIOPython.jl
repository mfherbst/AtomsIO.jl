module AtomsIOPython
using Reexport
@reexport using AtomsIO

export AseParser
include("ase.jl")

function AtomsIO.atomsio_extra_parsers(::AtomsIO.PythonParsers)
    # Register the python-based parsers with AtomsIO
    #
    # Note: For reproducibility reasons changing the order of these parsers is a
    # *breaking change* (as it alters the behaviour of AtomsIO.load_system).
    AbstractParser[AseParser(), ]
end

end
