import XCrySDenStructureFormat as XSF

"""
Parse or write file using [XCrySDenStructureFormat](https://github.com/azadoks/XCrySDenStructureFormat.jl).

Supported formats:
  - [XSF](http://www.xcrysden.org/doc/XSF.html) and [AXSF](XCrySDenStructureFormat)
    atomic structure files. These are the files typically used by the
    [XCrySDen](http://www.xcrysden.org/) visualisation program.
"""
struct XcrysdenstructureformatParser <: AbstractParser end

function supports_parsing(::XcrysdenstructureformatParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xsf", ".axsf")
end

function load_system(::XcrysdenstructureformatParser, file::AbstractString, index=nothing)
    if !isnothing(index)
        return XSF.load_xsf(file)[index]
    end


    frames = XSF.load_xsf(file)
    if !(frames isa AbstractVector)
        # load_xsf Returns plain structure in case only a single structure in the file
        return frames
    else
        isempty(frames) && error(
            "XSF returned no frames. Check the passed file is a valid (a)xsf file."
        )
        return last(frames)
    end
end

function save_system(::XcrysdenstructureformatParser,
                     file::AbstractString, system::AbstractSystem)
    XSF.save_xsf(file, system)
end

function load_trajectory(::XcrysdenstructureformatParser, file::AbstractString)
    # load_xsf Returns plain structure in case only a single structure in the file,
    # so we need to re-wrap to keep a consistent interface.
    ret = XSF.load_xsf(file)
    if !(ret isa AbstractVector)
        return [ret]
    else
        return ret
    end
end

function save_trajectory(::XcrysdenstructureformatParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    XSF.save_xsf(file, systems)
end
