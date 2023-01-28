module AtomsIO
using Reexport
@reexport using AtomsBase
using Requires
using Unitful
using UnitfulAtomic
import PeriodicTable

include("parser.jl")
include("chemfiles.jl")
include("extxyz.jl")

export load_system, save_system, load_trajectory, save_trajectory
export AbstractParser, ChemfilesParser, ExtxyzParser

function __init__()
    @require ASEconvert = "3da9722f-58c2-4165-81be-b4d7253e8fd2" begin
        include("ase.jl")
        export AseParser
    end
end

end
