import XCrySDenStructureFormat as XSF

"""
Parse or write file using [XSF](https://github.com/azadoks/XCrySDenStructureFormat.jl)

Supported formats:
  - [XSF](http://www.xcrysden.org/doc/XSF.html)
"""
struct XsfParser <: AbstractParser end

function supports_parsing(::XsfParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xsf", ".axsf")
end

function load_system(::XsfParser, file::AbstractString, index=nothing)
    if isnothing(index)
        frames = XSF.load_xsf(file)
        isempty(frames) && error(
            "XSF returned no frames. Check the passed file is a valid (a)xsf file."
        )
        return last(frames)
    else
        return XSF.load_xsf(file)[index]
    end
end

function save_system(::XsfParser, file::AbstractString, system::AbstractSystem)
    XSF.save_xsf(file, system)
end

function load_trajectory(::XsfParser, file::AbstractString)
    XSF.load_xsf(file)
end

function save_system(::XsfParser, file::AbstractString, system::AbstractSystem)
    XSF.save_xsf(file, system)
end

function save_trajectory(::XsfParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    XSF.save_xsf(file, systems)
end
