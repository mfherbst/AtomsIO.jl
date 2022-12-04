import Chemfiles
using Logging
using Unitful

struct ChemfilesParser <: AbstractParser end

function supports_parsing(::ChemfilesParser, file; save, trajectory)
    format = Logging.with_logger(NullLogger()) do
        Chemfiles.guess_format(file)
    end
    isempty(format) && return false

    filtered = filter(f -> f.name == format, Chemfiles.format_list())
    length(filtered) != 1 && return false

    if save && filtered[1].write
        return true
    elseif !save && filtered[1].write
        return true
    else
        return false
    end
end


function load_system(::ChemfilesParser, file::AbstractString; index=nothing)
    Chemfiles.Trajectory(file, 'r') do trajectory
        cfindex = something(index, length(trajectory)) - 1
        parse_chemfiles(Chemfiles.read_step(trajectory, cfindex))
    end
end

function save_system(::ChemfilesParser, file::AbstractString, system::AbstractSystem)
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
    pos = Chemfiles.positions(frame)
    unit_cell = Chemfiles.UnitCell(frame)
    cell = Chemfiles.matrix(unit_cell)
    topology = Chemfiles.Topology(frame)
    cell_shape = Chemfiles.shape(unit_cell)

    #Read each atom
    number_of_atoms = size(topology)
    atoms = Vector{AtomsBase.Atom}(undef, number_of_atoms)
    for i in 1:size(topology)
        cf_atom = Chemfiles.Atom(topology, i - 1)
        if Chemfiles.has_velocities(frame)
            ab_atom = AtomsBase.Atom(Chemfiles.atomic_number(cf_atom), pos[:,i]*u"Å", Chemfiles.velocities(frame)[:,i]*u"Å/ps")
        else
            ab_atom = AtomsBase.Atom(Chemfiles.atomic_number(cf_atom), pos[:,i]*u"Å")
        end
        #Read all properties of a Chemfiles atom
        atom_data = Dict{Symbol, Any}()
        for prop in Chemfiles.list_properties(cf_atom)
            if prop ∉ (:atomic_number, )
                atom_data[Symbol(prop)] = Chemfiles.property(cf_atom, prop)
            end
        end 
        ab_atom = AtomsBase.Atom(ab_atom; atom_data...)
        #Unitful doesn't know atomic charge e
        ab_atom = AtomsBase.Atom(ab_atom, charge=Chemfiles.charge(cf_atom), covalent_radius=Chemfiles.covalent_radius(cf_atom)*u"Å", vdw_radius=Chemfiles.vdw_radius(cf_atom)*u"Å")
        atoms[i] = ab_atom
    end

    #Transforming boundary box
    box = collect.(eachrow(cell)).*u"Å"

    #Transforming boundary condition -> Check for chemfiles boundary_conditions
    if(cell_shape == Chemfiles.Infinite)
        bcs = [DirichletZero(), DirichletZero(), DirichletZero()]
        @warn "bounding_box only contains zero vectors"
    else 
        bcs = [Periodic(), Periodic(), Periodic()]
    end

    #Read all properties of a Chemfiles frame
    system_data = Dict{Symbol, Any}(Symbol(Chemfiles.list_properties(frame)[i]) => Chemfiles.property(frame, Chemfiles.list_properties(frame)[i]) for i = 1:Chemfiles.properties_count(frame))
    atomic_system(atoms, box, bcs; system_data...)
end

function convert_chemfiles(system::AbstractSystem)
    # AtomsBase Commands NOT Chemfiles
    pos = position(system)
    vel = velocity(system)
    symbols = AtomsBase.atomic_symbol(system)
    box = bounding_box(system)
    bcs = boundary_conditions(system)
    n_dims = n_dimensions(system)
    per = periodicity(system)

    if n_dims != 3
        @error "Chemfiles only supports 3 Dimensions"
    end

    topology = Chemfiles.Topology()
    frame = Chemfiles.Frame()
    Chemfiles.set_topology!(frame, topology)
    
    # Adding the bounding box to the frame
    cf_box = zeros(Float64, 3, 3)
    for i = 1:3
        cf_box[i, :] = ustrip.(u"Å", box[i])
    end

    if(bcs[1] == DirichletZero() || bcs[2] == DirichletZero() || bcs[3] == DirichletZero())
        @warn "Chemfiles doesn't support the boundary_condition DirichletZero()"
    end

    # Adding boundary conditions
    cell = Chemfiles.UnitCell(cf_box)
    Chemfiles.set_cell!(frame, cell)

    # Adding position, velocity and symbol to each atom
    velocities_zero = ismissing(vel) || iszero(vel)
    for i in 1:lastindex(pos)
        cf_atom = Chemfiles.Atom(String(symbols[i]))
        
        atom_pos = convert(Vector{Float64}, ustrip.(u"Å", (pos[i])))
        if(velocities_zero)
            Chemfiles.add_atom!(frame, cf_atom, atom_pos)
        else
            atom_vel = convert(Vector{Float64}, ustrip.(u"Å/ps", (vel[i])))
            Chemfiles.add_atom!(frame, cf_atom, atom_pos, atom_vel)
        end
    end

    if system isa FlexibleSystem
        for (key, value) in system.data
            Chemfiles.set_property!(frame, string(key), value)
        end

        for i in 1:lastindex(system)
            atom_data = system[i].data
            delete!(atom_data, :charge)
            delete!(atom_data, :vdw_radius)
            delete!(atom_data, :covalent_radius)

            for (key, value) in atom_data
                Chemfiles.set_property!(frame[i-1], string(key), value)
            end
        end
    end

    return frame
end
