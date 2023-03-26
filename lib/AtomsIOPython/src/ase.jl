using ASEconvert

"""
*Requires `AtomsIOPython` to be loaded.*
Parse or write files using the Atomistic Simulation Environment (ASE)
via [ASEconvert](https://github.com/mfherbst/ASEconvert.jl).

Supported formats:  
  - [CIF](https://www.iucr.org/resources/cif) files
  - [Quantum Espresso](https://www.quantum-espresso.org/Doc/INPUT_PW.html) / [ABINIT](https://docs.abinit.org/variables/) / [VASP](https://www.vasp.at/wiki/) input files
  - ASE trajectory files
  - [XYZ](https://openbabel.org/wiki/XYZ) and [extxyz](https://github.com/libAtoms/extxyz#extended-xyz-specification-and-parsing-tools) files
"""
struct AseParser <: AbstractParser end


function AtomsIO.supports_parsing(::AseParser, file; save, trajectory)
    format = ""
    try
        format = ase.io.formats.filetype(file; read=!save, guess=false)
    catch e
        e isa PyException && return false
        rethrow()
    end

    if !(format in ase.io.formats.ioformats)
        return false
    elseif trajectory
        # Loading/saving multiple systems is supported only if + in code
        supports_trajectory = '+' in ase.io.formats.ioformats[format].code
        return supports_trajectory
    else
        return true
    end
end

function AtomsIO.load_system(::AseParser, file::AbstractString, index=nothing;
                             format=nothing)
    pyindex = isnothing(index) ? nothing : index - 1
    pyconvert(AbstractSystem, ase.io.read(file; format, index=pyindex))
end

function AtomsIO.save_system(::AseParser, file::AbstractString, system::AbstractSystem;
                             format=nothing)
    ase.io.write(file, convert_ase(system); format)
end

function AtomsIO.load_trajectory(::AseParser, file::AbstractString; format=nothing)
    systems = ase.io.read(file; format, index=":")
    pyconvert.(AbstractSystem, systems)
end

function AtomsIO.save_trajectory(::AseParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem}; format=nothing)
    ase.io.write(file, convert_ase.(systems); format)
end
