import ExtXYZ

"""
Parse or write file using [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)
"""
struct ExtxyzParser <: AbstractParser end

function supports_parsing(::ExtxyzParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xyz", ".extxyz")
end


function load_system(::ExtxyzParser, file::AbstractString, index=nothing)
    frame = (isnothing(index) ? last(ExtXYZ.read_frames(file))
                              : only(ExtXYZ.read_frames(file, index)))
    ExtXYZ.Atoms(frame)
end

function save_system(::ExtxyzParser, file::AbstractString, system::AbstractSystem)
    ExtXYZ.write_frame(file, ExtXYZ.write_dict(system))
end

function load_trajectory(::ExtxyzParser, file::AbstractString)
    ExtXYZ.Atoms.(ExtXYZ.read_frames(file))
end

function save_trajectory(::ExtxyzParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    ExtXYZ.write_frames(file, ExtXYZ.write_dict.(systems))
end
