using AtomsBase
using Test
using LinearAlgebra
using Unitful
using UnitfulAtomic

"""
Test whether two abstract systems are approximately the same. Certain atomic or system
properties can be ignored during the comparison using the respective kwargs.
"""
function test_approx_eq(s::AbstractSystem, t::AbstractSystem;
                        atol=1e-14, ignore_atprop=Symbol[], ignore_sysprop=Symbol[])
    # TODO Introduce an == / ≈ method in AbstractSystem for this purpose

    @test maximum(norm, position(s)     - position(t))     < atol * u"Å"
    @test maximum(norm, bounding_box(s) - bounding_box(t)) < atol * u"Å"

    if !(:velocity in ignore_atprop)
        @test ismissing(velocity(s)) == ismissing(velocity(t))
        if !ismissing(velocity(s)) && !ismissing(velocity(t))
            @test maximum(norm, velocity(s) - velocity(t)) < atol * u"Å/s"
        end
    end

    for method in (atomic_symbol, atomic_number, boundary_conditions)
        @test method(s) == method(t)
    end
    @test maximum(abs, atomic_mass(s) - atomic_mass(t)) < atol * u"u"

    extra_atomic_props = (:charge, :covalent_radius, :vdw_radius, :magnetic_moment)
    for prop in extra_atomic_props
        prop in ignore_atprop && continue
        for (at_s, at_t) in zip(s, t)
            @test hasproperty(at_s, prop) == hasproperty(at_t, prop)
            if hasproperty(at_s, prop) && hasproperty(at_t, prop)
                prop_s = getproperty(at_s, prop)
                prop_t = getproperty(at_t, prop)

                if prop_s isa Quantity
                    @test maximum(prop_s - prop_t) < atol * unit(prop_s)
                else
                    @test prop_s == prop_t
                end
            end
        end
    end

    if s isa FlexibleSystem && t isa FlexibleSystem
        for k in keys(s.data)
            k in ignore_sysprop && continue
            @test s.data[k] == t.data[k]
        end
    end
end

"""
Setup a standard test system using some random data and supply the data to the caller.
Extra atomic or system properties can be specified using `extra_atprop` and `extra_sysprop`
and specific standard keys can be ignored using `drop_atprop` and `drop_sysprop`.
"""
function make_test_system(D=3; drop_atprop=Symbol[], drop_sysprop=Symbol[],
                          extra_atprop=(; ), extra_sysprop=(; ), cellmatrix=:full)
    # TODO Should be moved to AtomsBase
    @assert D == 3
    n_atoms = 5

    # Generate some random data to store in Atoms
    atprop = Dict{Symbol,Any}(
        :position        => [randn(3) for _ = 1:n_atoms]u"Å",
        :velocity        => [randn(3) for _ = 1:n_atoms]u"Å/s",
        :atomic_symbol   => [:H, :H, :C, :N, :He],
        :atomic_number   => [1, 1, 6, 7, 2],
        :charge          => [2, 1, 3.0, -1.0, 0.0]u"e_au",
        :atomic_mass     => 10rand(n_atoms)u"u",
        :vdw_radius      => randn(n_atoms)u"Å",
        :covalent_radius => randn(n_atoms)u"Å",
        :magnetic_moment => [0.0, 0.0, 1.0, -1.0, 0.0],
    )
    sysprop = Dict{Symbol,Any}(
        :extra_data   => 42,
        :charge       => -1u"e_au",
        :multiplicity => 2,
    )

    for prop in drop_atprop
        pop!(atprop, prop)
    end
    for prop in drop_sysprop
        pop!(sysprop, prop)
    end
    sysprop = merge(sysprop, pairs(extra_sysprop))
    atprop  = merge(atprop,  pairs(extra_atprop))

    atoms = map(1:n_atoms) do i
        atargs = Dict(k => v[i] for (k, v) in pairs(atprop)
                      if !(k in (:position, :velocity)))
        if haskey(atprop, :velocity)
            Atom(atprop[:atomic_symbol][i], atprop[:position][i], atprop[:velocity][i];
                 atargs...)
        else
            Atom(atprop[:atomic_symbol][i], atprop[:position][i]; atargs...)
        end
    end
    if cellmatrix == :upper_triangular
        box = [[1.54732, -0.807289, -0.500870],
               [    0.0, 0.4654985, 0.5615117],
               [    0.0,       0.0, 0.7928950]]u"Å"
    elseif cellmatrix == :lower_triangular
        box = [[1.54732, 0.0, 0.0],
               [-0.807289, 0.4654985, 0.0],
               [-0.500870, 0.5615117, 0.7928950]]u"Å"
    else
        box = [[-1.50304, 0.850344, 0.717239],
               [ 0.36113, 0.008144, 0.814712],
               [ 0.06828, 0.381122, 0.129081]]u"Å"
    end
    bcs = [Periodic(), Periodic(), DirichletZero()]
    system = atomic_system(atoms, box, bcs; sysprop...)

    (; system, atoms, atprop=NamedTuple(atprop), sysprop=NamedTuple(sysprop), box, bcs)
end
