import Chemfiles
using Logging

"""
Parse or write file using [Chemfiles](https://github.com/chemfiles/Chemfiles.jl).
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
        cfindex = something(index, length(trajectory)) - 1
        parse_chemfiles(Chemfiles.read_step(trajectory, cfindex))
    end
end

function save_system(::ChemfilesParser, file::AbstractString, system::AbstractSystem)
    # TODO Warn if some data is contained in the system, where Chemfiles says
    # it cannot be written
    Chemfiles.Trajectory(file, 'w') do trajectory
        write(trajectory, convert_chemfiles(system))
    end
end

function load_trajectory(::ChemfilesParser, file::AbstractString)
    Chemfiles.Trajectory(file, 'r') do trajectory
        map(0:length(trajectory)-1) do ci
            parse_chemfiles(Chemfiles.read_step(trajectory, ci))
        end
    end
end

function save_trajectory(::ChemfilesParser, file::AbstractString,
                         systems::AbstractVector{<:AbstractSystem})
    Chemfiles.Trajectory(file, 'w') do trajectory
        for system in systems
            write(trajectory, convert_chemfiles(system))
        end
    end
end

#
# Convert to/from Chemfiles.Frame
#

function parse_chemfiles(frame::Chemfiles.Frame)
    # TODO Should be moved to Chemfiles as a
    #      convert(AbstractSystem, ::Chemfile.Frame)

    # Regarding the unit conventions, see:
    # https://chemfiles.org/chemfiles/latest/overview.html#units
    #
    atoms = map(1:length(frame), frame) do i, atom
        pos = Chemfiles.positions(frame)[:, i]u"Å"
        if Chemfiles.has_velocities(frame)
            velocity = Chemfiles.velocities(frame)[:, i]u"Å/ps"
        else
            velocity = zeros(3)u"Å/ps"
        end

        # Collect atomic properties
        atprops = Dict(
            :atomic_mass     => Chemfiles.mass(atom)u"u",
            :atomic_symbol   => Symbol(Chemfiles.name(atom)),
            :atomic_number   => Chemfiles.atomic_number(atom),
            :charge          => Chemfiles.charge(atom)u"e_au",
            :covalent_radius => Chemfiles.covalent_radius(atom)u"Å",
            :vdw_radius      => Chemfiles.vdw_radius(atom)*u"Å",
        )
        for prop in Chemfiles.list_properties(atom)
            symbol = Symbol(prop)
            if !hasfield(Atom, symbol) && !(symbol in keys(atprops))
                atprops[symbol] = Chemfiles.property(atom, prop)
            end
        end

        Atom(Chemfiles.atomic_number(atom), pos, velocity; atprops...)
    end

    # Collect system properties
    sysprops = Dict{Symbol,Any}()
    for prop in Chemfiles.list_properties(frame)
        if hasfield(FlexibleSystem, Symbol(prop))
            continue
        elseif prop == "charge"
            value = Chemfiles.property(frame, "charge")
            value isa AbstractString && (value = parse(Float64, value))  # Work around a bug
            sysprops[:charge] = Float64(value)u"e_au"
        elseif prop == "multiplicity"
            value = Chemfiles.property(frame, "multiplicity")
            value isa AbstractString && (value = parse(Float64, value))  # Work around a bug
            sysprops[:multiplicity] = Int(value)
        else
            sysprops[Symbol(prop)] = Chemfiles.property(frame, prop)
        end
    end

    # Construct system
    cell_shape = Chemfiles.shape(Chemfiles.UnitCell(frame))
    if cell_shape == Chemfiles.Infinite
        isolated_system(atoms; sysprops...)
    else
        @assert cell_shape in (Chemfiles.Triclinic, Chemfiles.Orthorhombic)
        box = collect(eachrow(Chemfiles.matrix(Chemfiles.UnitCell(frame))))u"Å"
        periodic_system(atoms, box; sysprops...)
    end
end

function convert_chemfiles(system::AbstractSystem{D}) where {D}
    # TODO Should be moved to Chemfiles as a
    #      convert(Chemfiles.Frame, ::AbstractSystem)

    D != 3 && @warn "1D and 2D systems not yet fully supported."
    frame = Chemfiles.Frame()

    # Cell and boundary conditions
    if bounding_box(system) == infinite_box(D)  # System is infinite
        cell = Chemfiles.UnitCell(zeros(3, 3))
        Chemfiles.set_shape!(cell, Chemfiles.Infinite)
        Chemfiles.set_cell!(frame, cell)
    else
        if any(!isequal(Periodic()), boundary_conditions(system))
            @warn("Ignoring specified boundary conditions: Chemfiles only supports " *
                  "infinite or all-periodic boundary conditions.")
        end

        box = zeros(3, 3)
        for i = 1:D
            box[i, 1:D] = ustrip.(u"Å", bounding_box(system)[i])
        end
        cell = Chemfiles.UnitCell(box)
        Chemfiles.set_cell!(frame, cell)
    end

    if any(atom -> !ismissing(velocity(atom)), system)
        Chemfiles.add_velocities!(frame)
    end
    for atom in system
        # We are using the atomic_number here, since in AtomsBase the atomic_symbol
        # can be more elaborate (e.g. D instead of H or "¹⁸O" instead of just "O").
        # In Chemfiles this is solved using the "name" of an atom ... to which we
        # map the AtomsBase.atomic_symbol.
        cf_atom = Chemfiles.Atom(PeriodicTable.elements[atomic_number(atom)].symbol)
        Chemfiles.set_name!(cf_atom, string(atomic_symbol(atom)))
        Chemfiles.set_mass!(cf_atom, ustrip(u"u", atomic_mass(atom)))
        @assert Chemfiles.atomic_number(cf_atom) == atomic_number(atom)

        for (k, v) in pairs(atom)
            if k in (:atomic_symbol, :atomic_number, :atomic_mass, :velocity, :position)
                continue  # Dealt with separately
            elseif k == :charge
                Chemfiles.set_charge!(cf_atom, ustrip(u"e_au", v))
            elseif k == :vdw_radius
                if v != Chemfiles.vdw_radius(cf_atom)u"Å"
                    @warn "Atom vdw_radius in Chemfiles cannot be mutated"
                end
            elseif k == :covalent_radius
                if v != Chemfiles.covalent_radius(cf_atom)u"Å"
                    @warn "Atom covalent_radius in Chemfiles cannot be mutated"
                end
            elseif v isa Union{Bool, Float64, String, Vector{Float64}}
                Chemfiles.set_property!(cf_atom, string(k), v)
            else
                @warn "Ignoring unsupported property type $(typeof(v)) in Chemfiles for key $k"
            end
        end

        pos = convert(Vector{Float64}, ustrip.(u"Å", position(atom)))
        if ismissing(velocity(atom))
            Chemfiles.add_atom!(frame, cf_atom, pos)
        else
            vel = convert(Vector{Float64}, ustrip.(u"Å/ps", velocity(atom)))
            Chemfiles.add_atom!(frame, cf_atom, pos, vel)
        end
    end

    for (k, v) in pairs(system)
        if k in (:bounding_box, :boundary_conditions)
            continue  # Already dealt with
        elseif k in (:charge, )
            Chemfiles.set_property!(frame, string(k), Float64(ustrip(u"e_au", v)))
        elseif k in (:multiplicity, )
            Chemfiles.set_property!(frame, string(k), Float64(v))
        elseif v isa Union{Bool, Float64, String, Vector{Float64}}
            Chemfiles.set_property!(frame, string(k), v)
        else
            @warn "Ignoring unsupported property type $(typeof(v)) in Chemfiles for key $k"
        end
    end

    frame
end
