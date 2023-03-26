module AtomsIOPython
using Reexport
@reexport using AtomsIO

include("ase.jl")

export AseParser

function __init__()
    # Append python-based parsers to the parser list in AtomsIO.
    # Note: For reproducibility reasons changing the order of these parsers is a
    # *breaking change* (as it alters the behaviour of AtomsIO.load_system).
    # Moreover since not all users will want to rely on Python dependencies, it is
    # crucial that the python-based parsers are *appended* to this list.
    parsers = AbstractParser[AseParser(), ]
    append!(AtomsIO.DEFAULT_PARSER_ORDER, parsers)
end
end
