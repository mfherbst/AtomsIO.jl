module AtomsIOXCrySDenStructureFormatExt

import XCrySDenStructureFormat as XSF
using AtomsIO

function AtomsIO.supports_parsing(::XcrysdenstructureformatParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xsf", ".axsf")
end

function AtomsIO.load_system(::XcrysdenstructureformatParser, file::AbstractString, index=nothing)
    frames = XSF.load_xsf(file)
    isempty(frames) && error(
        "XSF returned no frames. Check the passed file is a valid (a)xsf file."
    )
    if isnothing(index)
        return last(frames)
    else
        return frames[index]
    end
end

function AtomsIO.save_system(::XcrysdenstructureformatParser,
                     file::AbstractString, system::AbstractSystem)
    XSF.save_xsf(file, system)
end

function AtomsIO.load_trajectory(::XcrysdenstructureformatParser, file::AbstractString)
    XSF.load_xsf(file)
end

function AtomsIO.save_trajectory(::XcrysdenstructureformatParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    XSF.save_xsf(file, systems)
end

end
