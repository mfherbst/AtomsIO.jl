import XCrySDenStructureFormat as XSF

"""
Parse or write file using [XCrySDenStructureFormat](https://github.com/azadoks/XCrySDenStructureFormat.jl).

Supported formats:
  - [XSF](http://www.xcrysden.org/doc/XSF.html) and [AXSF](http://www.xcrysden.org/doc/XSF.html)
    atomic structure files. These are the files typically used by the
    [XCrySDen](http://www.xcrysden.org/) visualisation program.
"""
struct XcrysdenstructureformatParser <: AbstractParser end

function supports_parsing(::XcrysdenstructureformatParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xsf", ".axsf")
end

function load_system(::XcrysdenstructureformatParser, file::AbstractString, index=nothing)
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

function save_system(::XcrysdenstructureformatParser,
                     file::AbstractString, system::AbstractSystem)
    XSF.save_xsf(file, system)
end

function load_trajectory(::XcrysdenstructureformatParser, file::AbstractString)
    XSF.load_xsf(file)
end

function save_trajectory(::XcrysdenstructureformatParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    XSF.save_xsf(file, systems)
end
