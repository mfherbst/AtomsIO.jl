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
Base.@kwdef struct AseParser <: AbstractParser
    guess::Bool = true
end


function AtomsIO.supports_parsing(parser::AseParser, file; save, trajectory)
    format = ""

    if !save && !parser.guess
        @warn("There is a bug in ASE (as of 08/11/2023, ASE 3.22), which gets triggered " *
              "when trying to read files with `AseParser(; guess=false)`. This could mean " *
              "that AtomsIO falsely reports a file as unsupported even though it is indeed " *
              "supported for reading with ASE. In this case use `AseParser(; guess=true)` and" *
              "try again.")
    end

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
    supports_trajectory = '+' in ioformat.code
    if save && !pyconvert(Bool, ioformat.can_write)
        return false  # Want to write, but ASE cannot write
    elseif !save && !pyconvert(Bool, ioformat.can_read)
        return false  # Want to read, but ASE cannot read
    elseif trajectory && !supports_trajectory
        return false  # Trajectory operations, but not supported by ASE
    end

    true # We got here, so all is good
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
