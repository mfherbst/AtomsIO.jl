import ExtXYZ

"""
Parse or write file using [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)

Supported formats:  
  - [XYZ](https://openbabel.org/wiki/XYZ) and [extxyz](https://github.com/libAtoms/extxyz#extended-xyz-specification-and-parsing-tools) files
"""
struct ExtxyzParser <: AbstractParser end

function supports_parsing(::ExtxyzParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xyz", ".extxyz")
end

function load_system(::ExtxyzParser, file::AbstractString, index=nothing)
    if isnothing(index)
        frames = ExtXYZ.read_frames(file)
        isempty(frames) && error(
            "ExtXYZ returned no frames. Check the passed file is a valid (ext)xyz file."
        )
        return ExtXYZ.Atoms(last(frames))
    else
        frame = only(ExtXYZ.read_frames(file, index))
        return ExtXYZ.Atoms(frame)
    end
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
