module AtomsIOExtXYZExt

import ExtXYZ
using AtomsIO

function AtomsIO.supports_parsing(::ExtxyzParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xyz", ".extxyz")
end


function _extxyz_read_frames(args...; kwargs...)
    frames = nothing
    try
        frames = ExtXYZ.read_frames(args...; kwargs...)
    catch e
        # Version branch is needed because current_exceptions only
        # appeared in 1.7
        if VERSION ≥ v"1.7" && e isa TaskFailedException
            cur_e = last(current_exceptions(e.task))
            rethrow(cur_e.exception)
        else
            rethrow()
        end
    end
    if isnothing(frames) || isempty(frames)
        error("ExtXYZ returned no frames. Check the passed file is a valid (ext)xyz file.")
    end
    frames
end

function AtomsIO.load_system(::ExtxyzParser, file::AbstractString, index=nothing)
    if isnothing(index)
        frames = _extxyz_read_frames(file)
        return ExtXYZ.Atoms(last(frames))
    else
        frame = only(_extxyz_read_frames(file, index))
        return ExtXYZ.Atoms(frame)
    end
end

function AtomsIO.save_system(::ExtxyzParser, file::AbstractString, system::AbstractSystem)
    ExtXYZ.write_frame(file, ExtXYZ.write_dict(system))
end

function AtomsIO.load_trajectory(::ExtxyzParser, file::AbstractString)
    ExtXYZ.Atoms.(_extxyz_read_frames(file))
end

function AtomsIO.save_trajectory(::ExtxyzParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    ExtXYZ.write_frames(file, ExtXYZ.write_dict.(systems))
end

end
