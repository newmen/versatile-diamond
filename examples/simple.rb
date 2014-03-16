elements
  atom H, valence: 1
  atom C, valence: 4

dimensions
  temperature 'K'
  concentration 'mol/cm3'
  energy 'kcal/mol'
  rate '1/s'
  time 's'

gas
  spec :hydrogen
    atoms h: H

  spec :methane
    atoms c: C

  concentration hydrogen(h: *), 1e-9
  concentration methane(c: *), 1e-10
  temperature 1200

surface
  lattice :d, class: Diamond

  spec :bridge
    atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl, face: 110, dir: :cross
    bond :ct, :cr, face: 110, dir: :cross

  spec :methyl_on_bridge
    aliases basis: bridge
    atoms cm: methane(:c), cb: basis(:ct), cl: basis(:cl), cr: basis(:cr)
    bond :cm, :cb

  spec :high_bridge # may describe by methyl_on_bridge
    atoms ch: methane(:c), ct: bridge(:ct)
    dbond :ch, :ct

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_dimer
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_111
    atoms cm: C, cb: bridge(:cr)
    bond :cm, :cb

  spec :bridge_with_dimer
    atoms ct: C%d, cl: bridge(:ct), cr: dimer(:cr)
    bond :ct, :cl, face: 110, dir: :cross
    bond :ct, :cr, face: 110, dir: :cross

  spec :two_bridges
    atoms ctl: C%d, cl: bridge(:ct), cc: bridge(:cr)
    bond :ctl, :cl, face: 110, dir: :cross
    bond :ctl, :cc, face: 110, dir: :cross

  temperature 1000

events
  reaction 'surface activation'
    equation H + hydrogen(h: *) = * + hydrogen
    activation 6.65
    forward_rate 5.2e13, 'cm3/(mol * s)'

  reaction 'surface deactivation'
    equation * + hydrogen(h: *) = H
    activation 0
    forward_rate 2e13, 'cm3/(mol * s)'

  reaction 'methyl adsorption to dimer'
    equation dimer(cr: *) + methane(c: *) = methyl_on_dimer
    enthalpy -73.6
    activation 0
    forward_rate 1e13, 'cm3/(mol * s)'
    reverse_rate 5.3e3

  reaction 'methyl activation'
    # TODO: need to know that methyl_on_dimer on left side should have H at :cm
    equation methyl_on_dimer(cm: H) + hydrogen(h: *) = methyl_on_dimer(cm: *) + hydrogen
      incoherent methyl_on_dimer(:cm)
      unfixed methyl_on_dimer(:cm)

    activation 37.5
    forward_rate 2.8e8 * T ** 3.5, 'cm3/(mol * s)'

  reaction 'methyl deactivation'
    equation methyl_on_dimer(cm: *) + hydrogen(h: *) = methyl_on_dimer(cm: H)
      incoherent methyl_on_dimer(:cm)
      unfixed methyl_on_dimer(:cm)

    activation 0
    forward_rate 4.5e13, 'cm3/(mol * s)'

  environment :dimers_row
    targets :one_atom, :two_atom
    aliases left: dimer, right: dimer

    where :end_row, 'at end of dimers row'
      position one_atom, left(:cl), face: 100, dir: :cross
      position two_atom, left(:cr), face: 100, dir: :cross

    where :mid_row, 'in middle of dimers row'
      use :end_row
      position one_atom, right(:cl), face: 100, dir: :cross
      position two_atom, right(:cr), face: 100, dir: :cross

  reaction 'dimer formation between incoherent bridges'
    aliases one: bridge, two: bridge
    equation one(ct: *) + two(ct: *) = dimer
      incoherent one(:ct), two(:ct)

      refinement 'not in dimers row'
        enthalpy -36
        activation 0.8

      lateral :dimers_row, one_atom: one(:ct), two_atom: two(:ct)

      there :end_row
        enthalpy -39
        forward_activation 0.4
        reverse_activation 1

      there :mid_row
        enthalpy -43
        forward_activation 0
        reverse_activation 1.2

    forward_rate 8.9e11
    reverse_rate 2.2e6

  reaction 'methyl to high bridge'
    equation methyl_on_dimer(cm: *) = bridge(ct: *) + high_bridge
      unfixed methyl_on_dimer(:cm)

    forward_activation 15.3
    reverse_activation 2.9
    forward_rate 9.8e12
    reverse_rate 2.7e11

  reaction 'high bridge to two bridges on three'
    equation high_bridge + bridge(cr: *) = two_bridges(cl: *)
    activation 3.2
    forward_rate 2.9e11
    reverse_rate 1.1e8

  # additional reactions for check engine recipes
  reaction 'methyl adsorption to bridge'
    equation bridge(ct: *, ct: i) + methane(c: *) = methyl_on_bridge
    activation 0
    reverse_rate 1.7e7

  reaction 'methyl adsorption to face 111'
    equation bridge(cr: *) + methane(c: *) = methyl_on_111
    activation 0
    forward_rate 1.2e-1, 'cm3/(mol * s)'
    reverse_rate 5.4e6

  reaction 'same methyl-dimer hydrogen migration'
    # TODO: there is way to not specify H atom
    equation methyl_on_dimer(cm: *, cl: H) = methyl_on_dimer(cl: *, cm: H)
      unfixed methyl_on_dimer(:cm)

    forward_activation 37.5
    forward_rate 2.1e12
    reverse_activation 50.5
    reverse_rate 1.2e12

  reaction 'high bridge is stand to incoherent bridge'
    aliases source: bridge, product: bridge
    equation high_bridge + source(ct: *, ct: i) = product(cr: *)

    enthalpy 24
    activation 14.9
    forward_rate 6.1e13
    reverse_rate 1.1e12

  reaction 'high bridge to bridge and dimer'
    equation high_bridge + dimer(cr: *, cl: i) = bridge_with_dimer(cl: *)
    activation 14.9
    forward_rate 2.2e9
    reverse_rate 4.2e8

  reaction 'methyl to dimer (incorporate down at 100 face)'
    aliases source: dimer, product: dimer
    equation methyl_on_bridge(cm: *, cm: u, cb: i) + source(cr: *) = product
      position methyl_on_bridge(:cl), source(:cl), face: 100, dir: :cross
      position methyl_on_bridge(:cr), source(:cr), face: 100, dir: :cross

    activation 31.3
    forward_rate 3.5e8

  reaction 'hydrogen abstraction from gap'
    aliases one: bridge, two: bridge
    equation one(cr: H) + two(cr: H) = one(cr: *) + two(cr: *) + hydrogen
    activation 35
    forward_rate 3e5
