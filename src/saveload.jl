# The list of parsers in the order to try them.
# Python-based parsers are appended once AtomsIOPython is loaded.
# Note: For reproducibility reasons changing the order of these parsers is a
# *breaking change* (as it alters the behaviour of AtomsIO.load_system).
# Moreover since not all users will want to rely on Python dependencies, it is
# crucial that the python packages are only *appended* to this list.
const DEFAULT_PARSER_ORDER = AbstractParser[ExtxyzParser(), ChemfilesParser()]

function determine_parser(file; save=false, trajectory=false)
    idx_parser = findfirst(DEFAULT_PARSER_ORDER) do parser
        supports_parsing(parser, file; save, trajectory)
    end
    if isnothing(idx_parser)
        type = trajectory ? "trajectory" : "system"
        operation = save ? "save" : "load"

        errormsg = "Could not find a parser to $operation $type from/to file $file."
        if !isdefined(Main, :AtomsIOPython)
            errormsg *= " Try activating the python parsers by 'using AtomsIOPython'."
        end
        error(errormsg)
    end
    DEFAULT_PARSER_ORDER[idx_parser]
end


"""
    load_system([parser], file::AbstractString; kwargs...)
    load_system([parser], file::AbstractString, index; kwargs...)

Read an AtomsBase-compatible system from `file`. If `file` contains more than one structure
the last entry is returned. If `index` is specified this indexes into the list of structures
and returns the respective system.

By default `AtomsIO` picks an appropriate parser for the specified file format automatically.
A specific parser (such as [`ExtxyzParser`](@ref) or [`AseParser`](@ref)) can be enforced by
using it as the first argument. Some parsers support additional keyword arguments.
E.g. `AseParser` supports the `format` argument to overwrite the ASE-internal selection of
an input / output format.
"""
function load_system(file::AbstractString, index::Union{Nothing,Integer}=nothing; kwargs...)
    load_system(determine_parser(file; save=false, trajectory=false), file, index; kwargs...)
end

"""
    save_system([parser], file::AbstractString, system::AbstractSystem; kwargs...)

Save an AtomsBase-compatible system to the `file`. By default `AtomsIO` picks an appropriate
parser for the specified file format automatically. A specific parser
(such as [`ExtxyzParser`](@ref) or [`AseParser`](@ref)) can be enforced by
using it as the first argument. Some parsers support additional keyword arguments.
E.g. `AseParser` supports the `format` argument to overwrite the ASE-internal selection of
an input / output format.
"""
function save_system(file::AbstractString, system::AbstractSystem; kwargs...)
    save_system(determine_parser(file; save=true, trajectory=false), file, system; kwargs...)
end

"""
    load_trajectory([parser], file::AbstractString; kwargs...)

Read a trajectory from a `file` and return a vector of `AtomsBase`-compatible structures.
Providing a `parser` overwrites the automatic `AtomsIO` selection.
"""
function load_trajectory(file::AbstractString; kwargs...)
    load_trajectory(determine_parser(file; save=false, trajectory=true), file; kwargs...)
end

"""
    save_trajectory([parser], file::AbstractString, systems::AbstractVector; kwargs...)

Save a trajectory given as a list of `AtomsBase`-compatible systems to a `file`.
Providing a `parser` overwrites the automatic `AtomsIO` selection.
"""
function save_trajectory(file::AbstractString, systems::AbstractVector{<:AbstractSystem};
                         kwargs...)
    save_trajectory(determine_parser(file; save=true, trajectory=true), file, systems; kwargs...)
end
