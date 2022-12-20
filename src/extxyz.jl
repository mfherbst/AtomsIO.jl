import ExtXYZ

"""
Parse or write file using [ExtXYZ](https://github.com/libAtoms/ExtXYZ.jl)
"""
struct ExtxyzParser <: AbstractParser end

function supports_parsing(::ExtxyzParser, file; save, trajectory)
    _, ext = splitext(file)
    ext in (".xyz", ".extxyz")
end


function load_system(::ExtxyzParser, file::AbstractString, index=nothing)
    isfile(file) || throw(ArgumentError("File $file not found"))
    frame = (isnothing(index) ? last(ExtXYZ.read_frames(file))
                              : only(ExtXYZ.read_frames(file, index)))
    parse_extxyz(frame)
end

function save_system(::ExtxyzParser, file::AbstractString, system::AbstractSystem)
    ExtXYZ.write_frame(file, convert_extxyz(system))
end

function load_trajectory(::ExtxyzParser, file::AbstractString)
    isfile(file) || throw(ArgumentError("File $file not found"))
    parse_extxyz.(ExtXYZ.read_frames(file))
end

function save_trajectory(::ExtxyzParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    ExtXYZ.write_frames(file, convert_extxyz.(systems))
end

#
# Convert to/from ExtXYZ.Atoms
#

function parse_extxyz(dict::Dict{String, Any})
    # TODO Move this upstream to replace the current implementation of ExtXYZ.Atoms
    arrays = dict["arrays"]
    info   = dict["info"]

    if haskey(arrays, "Z")
        Z = Int.(arrays["Z"])
    elseif haskey(arrays, "species")
        Z = [PeriodicTable.elements[Symbol(spec)].number for spec in arrays["species"]]
    else
        error("Cannot determine atomic numbers. Either 'Z' or 'species' must " *
              "be present in arrays")
    end
    @assert length(Z) == dict["N_atoms"]

    atom_data = Dict{Symbol, Any}(
        :positions      => collect(eachcol(arrays["pos"]))u"Å",
        :atomic_numbers => Z,
    )
    if haskey(arrays, "species")
        atom_data[:atomic_symbols] = Symbol.(arrays["species"])
    else
        atom_data[:atomic_symbols] = [Symbol(element(num).symbol) for num in Z]
    end
    if haskey(arrays, "mass")
        atom_data[:atomic_masses] = arrays["mass"]u"u"
    else
        atom_data[:atomic_masses] = [PeriodicTable.elements[num].atomic_mass for num in Z]
    end
    if haskey(arrays, "velocities")
        atom_data[:velocities] = collect(eachcol(arrays["velocities"]))u"Å/s"
    end

    for key in keys(arrays)
        key in ("mass", "species", "Z", "pos", "velocities") && continue  # Already done
        if key in ("vdw_radius", "covalent_radius")  # Add length unit
            atom_data[Symbol(key)] = arrays[key] * u"Å"
        elseif key in ("charge", )  # Add charge unit
            atom_data[Symbol(key)] = arrays[key] * u"e_au"
        else
            atom_data[Symbol(key)] = arrays[key]
        end
    end

    system_data = Dict{Symbol, Any}(
        :box => collect(eachrow(dict["cell"]))u"Å",
    )
    if haskey(dict, "pbc")
        system_data[:boundary_conditions] = [p ? Periodic() : DirichletZero()
                                             for p in dict["pbc"]]
    else
        @warn "'pbc' not contained in 'info' dict. Defaulting to all-periodic boundary. "
        system_data[:boundary_conditions] = fill(Periodic(), 3)
    end

    for key in keys(info)
        if key in ("charge", )
            system_data[Symbol(key)] = info[key] * u"e_au"
        else
            system_data[Symbol(key)] = info[key]
        end
    end

    extxyz_atoms = ExtXYZ.Atoms(NamedTuple(atom_data), NamedTuple(system_data))

    # TODO Once ExtXYZ.Atoms supports atom and system property access,
    #      this is no longer needed
    atoms = map(1:length(extxyz_atoms), extxyz_atoms) do i, atom
        atprops = Dict{Symbol,Any}()
        for k in keys(atom_data)
            if !(k in (:atomic_number, :atomic_symbol, :atomic_mass, :position, :velocity))
                atprops[k] = atom_data[k][i]
            end
        end
        Atom(; atom, atprops...)
    end
    extra = Dict{Symbol,Any}()
    for k in keys(system_data)
        if !(k in (:box, :boundary_conditions))
            extra[k] = system_data[k]
        end
    end
    FlexibleSystem(atoms, bounding_box(extxyz_atoms),
                   boundary_conditions(extxyz_atoms); extra...)
end


function convert_extxyz(system::AbstractSystem)
    dict  = ExtXYZ.write_dict(make_atoms(system))

    # Strip off units from the AtomsBase-supported extra properties
    # (the ones where units are attached back on in parse_extxyz
    for k in keys(dict["arrays"])
        if k in ("charge", "vdw_radius", "covalent_radius")
            dict["arrays"][k] = austrip.(dict["arrays"][k])
        end
    end
    for k in keys(dict["info"])
        if k in ("charge", )
            dict["info"][k] = austrip.(dict["info"][k])
        end
    end

    # Fix velocities (which write_dict currently gets wrong)
    # TODO Fix upstream
    velocities = map(system) do atom
        vel = zeros(3)
        if !ismissing(velocity(atom))
            vel[1:n_dimensions(system)] = ustrip.(u"Å/s", velocity(atom))
        end
        vel
    end
    dict["arrays"]["velocities"] = hcat(velocities...)

    dict
end

function make_atoms(system::AbstractSystem{D}) where {D}
    D != 3 && @warn "1D and 2D systems not yet fully supported."

    # Types supported losslessly in ExtXYZ
    ExtxyzType = Union{Integer, AbstractFloat, AbstractString}

    n_atoms = length(system)
    atomic_symbols = [Symbol(PeriodicTable.elements[atomic_number(at)].symbol)
                      for at in system]
    if atomic_symbols != atomic_symbol(system)
        @warn("Mismatch between atomic numbers and atomic symbols, which is not supported " *
              "in ExtXYZ. Atomic numbers take preference.")
    end
    atom_data = Dict{Symbol,Any}(
        :atomic_symbols => atomic_symbols,
        :atomic_numbers => atomic_number(system),
        :atomic_masses  => atomic_mass(system)
    )
    atom_data[:positions] = map(1:n_atoms) do at
        pos = zeros(3)u"Å"
        pos[1:D] = position(system, at)
        pos
    end
    atom_data[:velocities] = map(1:n_atoms) do at
        vel = zeros(3)u"Å/s"
        if !ismissing(velocity(system)) && !ismissing(velocity(system, at))
            vel[1:D] = velocity(system, at)
        end
        vel
    end

    # Extract extra atomic properties
    if first(system) isa Atom
        # TODO not a good idea to directly access the field
        # TODO Implement and make use of a property interface on the atom level
        for (k, v) in system[1].data
            atoms_base_keys = (:charge, :covalent_radius, :vdw_radius,
                               :magnetic_moment, :pseudopotential)
            if k in atoms_base_keys || v isa ExtxyzType
                # These are either Unitful quantities, which are uniformly supported
                # across all of AtomsBase or the value has a type that Extxyz can write
                # losslessly, so we can just write them no matter the value
                atom_data[k] = [at.data[k] for at in system]
            elseif v isa Quantity || (v isa AbstractArray && eltype(v) <: Quantity)
                @warn "Unitful quantity $k is not yet supported in convert_extxyz."
            else
                @warn "Writing quantities of type $(typeof(v)) is not supported in convert_extxyz."
            end
        end
    end

    box = map(1:3) do i
        v = zeros(3)u"Å"
        i ≤ D && (v[1:D] = bounding_box(system)[i])
        v
    end
    system_data = Dict{Symbol,Any}(
        :box => box,
        :boundary_conditions => boundary_conditions(system)
    )

    # Extract extra system properties
    if system isa FlexibleSystem
        # TODO not a good idea to directly access the field
        # TODO Implement and make use of a property interface on the system level
        for (k, v) in system.data
            atoms_base_keys = (:charge, :multiplicity)
            if k in atoms_base_keys || v isa ExtxyzType
                # These are either Unitful quantities, which are uniformly supported
                # across all of AtomsBase or the value has a type that Extxyz can write
                # losslessly, so we can just write them no matter the value
                system_data[k] = v
            elseif v isa Quantity || (v isa AbstractArray && eltype(v) <: Quantity)
                @warn "Unitful quantity $k is not yet supported in convert_extxyz."
            else
                @warn "Writing quantities of type $(typeof(v)) is not supported in convert_extxyz."
            end
        end
    end

    ExtXYZ.Atoms(NamedTuple(atom_data), NamedTuple(system_data))
end
make_atoms(system::ExtXYZ.Atoms) = system
