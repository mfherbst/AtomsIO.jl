# import XCrySDenStructureFormat as XSF

"""
Parse or write file using [XCrySDenStructureFormat](https://github.com/azadoks/XCrySDenStructureFormat.jl).

Supported formats:
  - [XSF](http://www.xcrysden.org/doc/XSF.html) and [AXSF](http://www.xcrysden.org/doc/XSF.html)
    atomic structure files. These are the files typically used by the
    [XCrySDen](http://www.xcrysden.org/) visualisation program.

!!! note "Format has been dropped in AtomsIO 0.3"
    This file format has been supported in earlier versions of AtomsIO, but is now
    dropped as the implementing packages lack a maintainer and no longer function
    with the most recent version of AtomsBase.
    In case of interest,
    see the [draft PR](https://github.com/azadoks/XCrySDenStructureFormat.jl/pull/6),
    which can be completed to re-enable support.

"""
struct XcrysdenstructureformatParser <: AbstractParser end

function supports_parsing(::XcrysdenstructureformatParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xsf", ".axsf")
end

function _xsf_error_out()
    error("Format has been dropped due to a lack of a maintainer for the " *
          "implementing package. See help of XcrysdenstructureformatParser struct " *
          "for details.")
end

function load_system(::XcrysdenstructureformatParser, file::AbstractString, index=nothing)
    _xsf_error_out()
    # frames = XSF.load_xsf(file)
    # isempty(frames) && error(
    #     "XSF returned no frames. Check the passed file is a valid (a)xsf file."
    # )
    # if isnothing(index)
    #     return last(frames)
    # else
    #     return frames[index]
    # end
end

function save_system(::XcrysdenstructureformatParser,
                     file::AbstractString, system::AbstractSystem)
    _xsf_error_out()
    # XSF.save_xsf(file, system)
end

function load_trajectory(::XcrysdenstructureformatParser, file::AbstractString)
    _xsf_error_out()
    # XSF.load_xsf(file)
end

function save_trajectory(::XcrysdenstructureformatParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    _xsf_error_out()
    # XSF.save_xsf(file, systems)
end
