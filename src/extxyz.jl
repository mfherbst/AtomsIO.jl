import ExtXYZ
using Unitful

struct ExtxyzParser <: AbstractParser end

function supports_parsing(::ExtxyzParser, file; save, trajectory)
    _, ext = splitext(file)
    ext == ".extxyz"
end


function load_system(::ExtxyzParser, file::AbstractString; index=nothing)
    frame = (isnothing(index) ? last(ExtXYZ.read_frames(file))
                              : ExtXYZ.read_frames(file, index))
    ExtXYZ.Atoms(frame)
end

function save_system(::ExtxyzParser, file::AbstractString, system::AbstractSystem)
    ExtXYZ.save(file, convert_extxyz(system))
end

function load_trajectory(::ExtxyzParser, file::AbstractString)
    ExtXYZ.Atoms.(ExtXYZ.read_frames(file))
end

function save_trajectory(::ExtxyzParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    ExtXYZ.write_frames(file, ExtXYZ.write_dict.(convert_extxyz.(systems)))
end

#
# Convert to ExtXYZ.Atoms
#

function convert_extxyz(system::AbstractSystem)
    dim = n_dimensions(system)
    natoms = length(system)

    # atom_data (positions, atomic_numbers, atomic_symbols, atomic_masses and velocities(if given))
    pos = [zeros(3) for _ in 1:natoms]*u"Å"
    [pos[i][1:dim] = position(system)[i] for i=1:natoms]
    at_num = AtomsBase.atomic_number(system)
    at_sym = atomic_symbol(system)
    at_mass = atomic_mass(system)
    natoms = length(system)
    atom_data = Dict(:positions => pos, :atomic_numbers => at_num, :atomic_symbols => at_sym, :atomic_masses => at_mass)
    velocities_zero = ismissing(velocity(system)) || iszero(velocity(system)) # if system has velocities
    if !velocities_zero
        vel = [zeros(3) for _ in 1:natoms]*u"Å/(Å*sqrt(u/eV))"
        [vel[i][1:dim] = velocity(system)[i] for i=1:natoms]
        push!(atom_data, :velocities => vel)
    end

    # system_data (boundary_conditions and bounding_box)
    pbc = Vector{BoundaryCondition}(undef, 3); fill!(pbc, DirichletZero())
    [pbc[i] = boundary_conditions(system)[i] for i=1:dim]
    box = [zeros(3) for _ in 1:3]*u"Å"
    [box[i][1:dim] = bounding_box(system)[i] for i=1:dim]
    system_data = Dict{Symbol, Any}(:box => box, :boundary_conditions => pbc)
    
    # get extra data about the system or each atom, if system is a FlexibleSystem
    if isa(system, FlexibleSystem)
        entries = collect(keys(system[1].data))
        len_entr = length(entries)
        info_atom = Dict{Symbol, Any}()
        for i=1:len_entr
            if all([haskey(system[j].data, entries[i]) for j=1:natoms])
                push!(info_atom, entries[i] => Vector{typeof(system[1].data[entries[i]])}(undef, natoms))
                [info_atom[entries[i]][j] = system[j].data[entries[i]] for j=1:natoms]
            end
        end
        for key in keys(info_atom)
            key in [:covalent_radius, :vdw_radius, :charge] && pop!(info_atom, key)
        end
        [push!(atom_data, key => info_atom[key]) for key in keys(info_atom)]
        info_system = deepcopy(system.data)
        [push!(system_data, key => info_system[key]) for key in keys(info_system)]
    end
    Atoms(NamedTuple(atom_data), NamedTuple(system_data))
end
