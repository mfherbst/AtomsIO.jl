


abstract type AbstractParser end
supports_parsing(::AbstractParser, file; save, trajectory) = false

function determine_parser(file; save=false, trajectory=false)
    # TODO For now the list of registered parsers is hard-coded
    registered_parsers = [ExtxyzParser(), ChemfilesParser(), AseParser()]

    idx_parser = findfirst(registered_parsers) do parser
        supports_parsing(parser, file; save, trajectory)
    end
    if isnothing(idx_parser)
        type = trajectory ? "trajectory" : "system"
        operation = save ? "save" : "load"
        error("Could not find a parser to $operation $type from file $file.")
    end
    registered_parsers[idx_parser]
end






"""

index
1
nothing means last is parsed
"""
function load_system(file::AbstractString; index=nothing, kwargs...)
    load_system(determine_parser(file; save=false, trajectory=false), file; index, kwargs...)
end

function save_system(file::AbstractString, system::AbstractSystem; kwargs...)
    save_system(determine_parser(file; save=true, trajectory=false), file, system; kwargs...)
end

function load_trajectory(file::AbstractString; kwargs...)
    load_trajectory(determine_parser(file; save=false, trajectory=true), file; kwargs...)
end

function save_trajectory(file::AbstractString, systems::AbstractVector{<:AbstractSystem};
                         kwargs...)
    save_trajectory(determine_parser(file; save=true, trajectory=true), file, systems; kwargs...)
end
