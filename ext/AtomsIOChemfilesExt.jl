module AtomsIOChemfilesExt

import Chemfiles
using Logging
using AtomsIO, Unitful, UnitfulAtomic

function AtomsIO.supports_parsing(::ChemfilesParser, file; save, trajectory)
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


function AtomsIO.load_system(::ChemfilesParser, file::AbstractString, index=nothing)
    Chemfiles.Trajectory(file, 'r') do trajectory
        cfindex = something(index, length(trajectory)) - 1  # chemfiles is 0-based
        convert(AbstractSystem, Chemfiles.read_step(trajectory, cfindex))
    end
end

function AtomsIO.save_system(::ChemfilesParser, file::AbstractString, system::AbstractSystem)
    Chemfiles.Trajectory(file, 'w') do trajectory
        write(trajectory, convert(Chemfiles.Frame, system))
    end
end

function AtomsIO.load_trajectory(::ChemfilesParser, file::AbstractString)
    Chemfiles.Trajectory(file, 'r') do trajectory
        map(0:length(trajectory)-1) do ci  # Chemfiles is 0-based
            convert(AbstractSystem, Chemfiles.read_step(trajectory, ci))
        end
    end
end

function AtomsIO.save_trajectory(::ChemfilesParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    Chemfiles.Trajectory(file, 'w') do trajectory
        for system in systems
            write(trajectory, convert(Chemfiles.Frame, system))
        end
    end
end

end
