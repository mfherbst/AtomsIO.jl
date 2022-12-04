using ASEconvert

"""
Ase supports additional kwarg format
"""
struct AseParser <: AbstractParser end


function supports_parsing(::AseParser, file; save, trajectory)
    format = ""
    try
        format = ase.io.formats.filetype(file; read=!save, guess=false)
    catch e
        e isa PyException && return false
        rethrow()
    end
    format in ase.io.formats.ioformats || return false

    # Loading/saving multiple systems is supported only if + in code
    supports_trajectory = '+' in ase.io.formats.ioformats[format].code
    trajectory && supports_trajectory
end



function load_system(::AseParser, file::AbstractString; index=nothing, format=nothing)
    pyindex = isnothing(index) ? nothing : index - 1
    pyconvert(AbstractSystem, ase.io.read(file; format, index=pyindex))
end

function save_system(::AseParser, file::AbstractString, system::AbstractSystem; format=nothing)
    ase.io.write(file, convert_ase(system); format)
end

function load_trajectory(::AseParser, file::AbstractString; format=nothing)
    systems = ase.io.read(file; format, index=":")
    pyconvert.(AbstractSystem, systems)
end

function save_trajectory(::AseParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem}; format=nothing)
    ase.io.write(file, convert_ase.(systems); format)
end
