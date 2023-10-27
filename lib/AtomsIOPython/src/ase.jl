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
@kwdef struct AseParser <: AbstractParser 
    guess::Bool = true
end


function AtomsIO.supports_parsing(parser::AseParser, file; save, trajectory)
    format = ""
    try
        # read=true causes ASE to open the file, read a few bytes and check for magic bytes
        format = ase.io.formats.filetype(file; read=!save, guess=parser.guess)
    catch e
        e isa PyException && return false
        rethrow()
    end

    if !(format in ase.io.formats.ioformats)
        return false
    end

    ioformat = ase.io.formats.ioformats[format]
    supports_trajectory = '+' in ase.io.formats.ioformats[format].code

    if save # Check whether ASE can write format
        if Bool(ioformat.can_write)
            if trajectory
                return supports_trajectory
            else
                return true
            end
        else
            return false
        end
    else # Check whether ASE can read format
        if Bool(ioformat.can_read)
            if trajectory
                return supports_trajectory
            else
                return true
            end
        else
            return false
        end
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
