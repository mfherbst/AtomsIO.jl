import Chemfiles
using Logging
using Unitful
using UnitfulAtomic

"""
Parse or write file using [Chemfiles](https://github.com/chemfiles/Chemfiles.jl).

Supported formats:  
  - [CIF](https://www.iucr.org/resources/cif) files
  - [Gromacs](http://manual.gromacs.org/archive/5.0.7/online/trj.html) / [LAMMPS](https://lammps.sandia.gov/doc/dump.html) / [Amber](http://ambermd.org/netcdf/nctraj.xhtml) trajectory files
"""
struct ChemfilesParser <: AbstractParser end

function supports_parsing(::ChemfilesParser, file; save, trajectory)
    format = Logging.with_logger(NullLogger()) do
        Chemfiles.guess_format(file)
    end
    isempty(format) && return false

    filtered = filter(f -> f.name == format, Chemfiles.format_list())
    length(filtered) != 1 && return false

    if save
        return filtered[1].write
    else
        return filtered[1].read
    end
end


function load_system(::ChemfilesParser, file::AbstractString, index=nothing)
    Chemfiles.Trajectory(file, 'r') do trajectory
        cfindex = something(index, length(trajectory)) - 1  # chemfiles is 0-based
        convert(AbstractSystem, Chemfiles.read_step(trajectory, cfindex))
    end
end

function save_system(::ChemfilesParser, file::AbstractString, system::AbstractSystem)
    Chemfiles.Trajectory(file, 'w') do trajectory
        write(trajectory, convert(Chemfiles.Frame, system))
    end
end

function load_trajectory(::ChemfilesParser, file::AbstractString)
    Chemfiles.Trajectory(file, 'r') do trajectory
        map(0:length(trajectory)-1) do ci  # Chemfiles is 0-based
            convert(AbstractSystem, Chemfiles.read_step(trajectory, ci))
        end
    end
end

function save_trajectory(::ChemfilesParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    Chemfiles.Trajectory(file, 'w') do trajectory
        for system in systems
            write(trajectory, convert(Chemfiles.Frame, system))
        end
    end
end
