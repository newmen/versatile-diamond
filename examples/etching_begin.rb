elements
  atom H, valence: 1
  atom C, valence: 4

dimensions
  temperature 'K'
  concentration 'mol/cm3'
  energy 'kJ/mol'
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

  spec :high_bridge
    atoms ch: methane(:c), ct: bridge(:ct)
    dbond :ch, :ct

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_dimer
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_dimer_with_bridge
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:cr), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_111
    atoms cm: C, cb: bridge(:cr)
    bond :cm, :cb

  spec :bridge_with_dimer
    atoms ct: C%d, cl: bridge(:ct), cr: dimer(:cr)
    bond :ct, :cl, face: 110, dir: :cross
    bond :ct, :cr, face: 110, dir: :cross

  spec :three_bridges
    atoms ctl: C%d, cl: bridge(:ct), cc: bridge(:cr)
    bond :ctl, :cl, face: 110, dir: :cross
    bond :ctl, :cc, face: 110, dir: :cross

  spec :cross_bridge_on_bridges
    atoms ct: C, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl
    bond :ct, :cr
    position :cl, :cr, face: 100, dir: :cross

  spec :cross_bridge_on_dimers
    aliases mod: methyl_on_dimer
    atoms ct: mod(:cm), cl: mod(:cr), cr: dimer(:cr)
    bond :ct, :cr
    position :cl, :cr, face: 100, dir: :cross

  spec :dimer_after_down_111
    atoms cl: bridge(:cr), cr: C%d, crs: bridge(:ct), cls: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front
    bond :cr, :crs, face: 110, dir: :cross
    bond :cr, :cls, face: 110, dir: :cross

  spec :dimer_after_gap_b
    atoms cls: bridge(:cr), crs: bridge(:cr), cr: C%d, cl: bridge(:ct)
    bond :cls, :cr, face: 110, dir: :front
    bond :crs, :cr, face: 110, dir: :front
    bond :cr, :cl, face: 100, dir: :front

  spec :dimer_after_gap_111
    atoms cls: bridge(:cr), crs: bridge(:cr), cr: C%d, cl: bridge(:cr)
    bond :cls, :cr, face: 110, dir: :front
    bond :crs, :cr, face: 110, dir: :front
    bond :cr, :cl, face: 100, dir: :front

  size x: 100, y: 100, z: 5
  temperature 1200

events
  reaction 'hydrogen abstraction from gap'
    aliases one: bridge, two: bridge
    equation one(cr: H) + two(cr: H) = one(cr: *) + two(cr: *) + hydrogen
      position one(:cr), two(:cr), face: 100, dir: :front

    activation 35
    forward_rate 3e5

  reaction 'methyl adsorption to face 111'
    equation bridge(cr: *) + methane(c: *) = methyl_on_111
    forward_rate 1.2e9, 'cm3/(mol * s)'

  reaction 'adsorption methyl to dimer'
    equation dimer(cr: *) + methane(c: *) = methyl_on_dimer
    enthalpy -73.6
    forward_rate 1e13, 'cm3/(mol * s)'

  reaction 'high bridge stand to dimer'
    equation high_bridge(ch: i) + dimer(cr: *, cl: i) = bridge_with_dimer(cl: *)
    activation 14.9
    forward_rate 2.2e9
    reverse_rate 4.2e8

  reaction 'desorption methyl from 111'
    equation methyl_on_111 + hydrogen(h: *) = bridge(cr: *) + methane
    forward_rate 5.4e13, 'cm3/(mol * s)'

  reaction 'desorption methyl from bridge'
    equation methyl_on_bridge + hydrogen(h: *) = bridge(ct: *, ct: i) + methane
    forward_rate 1.7e14, 'cm3/(mol * s)'

  reaction 'desorption methyl from dimer'
    equation methyl_on_dimer + hydrogen(h: *) = dimer(cr: *) + methane
    enthalpy -73.6
    forward_rate 5.3e12, 'cm3/(mol * s)'

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

  reaction 'dimer formation'
    aliases one: bridge, two: bridge
    equation one(ct: *) + two(ct: *) = dimer
      incoherent one(:ct), two(:ct)

      refinement 'not in dimers row'
        enthalpy -36
        activation 0.8

      lateral :dimers_row, one_atom: one(:ct), two_atom: two(:ct)

      there :end_row
        enthalpy -39
        forward_activation 0.75
        reverse_activation 0.85

      there :mid_row
        enthalpy -43
        forward_activation 0.7
        reverse_activation 0.9

    forward_rate 8.9e11
    reverse_rate 2.2e6

  reaction 'dimer formation near bridge'
    aliases one: bridge, two: bridge
    equation one(ct: *, ct: i) + two(cr: *) = bridge_with_dimer
    enthalpy -29.4
    activation 4
    forward_rate 7.5e8
    reverse_rate 1.2e8

  reaction 'high bridge stand to bridge at new level'
    aliases source: bridge, product: bridge
    equation high_bridge + source(ct: *, ct: i) = product(cr: *, ct: i)
    enthalpy 24
    # already exchanged!!
    reverse_activation 36.3
    reverse_rate 6.1e13
    forward_activation 12.3
    forward_rate 1.1e12

  reaction 'methyl to high bridge'
    equation methyl_on_dimer(cm: *, cm: u) = bridge(ct: *, ct: i) + high_bridge
    forward_activation 15.3
    reverse_activation 2.9
    forward_rate 9.8e12
    reverse_rate 2.7e11

  reaction 'methyl to high bridge near bridge'
    equation methyl_on_dimer_with_bridge(cm: *, cm: u) = bridge(cr: *) + high_bridge
    forward_activation 15.3
    reverse_activation 2.9
    forward_rate 9.8e9
    reverse_rate 2.7e8

  reaction 'high bridge incorporates in crystal lattice near another bridge'
    equation high_bridge(ch: i) + bridge(cr: *) = three_bridges(cl: *)
    activation 3.2
    forward_rate 2.9e11
    reverse_rate 1.1e8

  reaction 'methyl on dimer activation'
    equation methyl_on_dimer(cm: H, cm: i) + hydrogen(h: *) = methyl_on_dimer(cm: *) + hydrogen
    activation 37.5
    forward_rate 2.8e8 * T ** 3.5, 'cm3/(mol * s)'

  reaction 'methyl on dimer deactivation'
    equation methyl_on_dimer(cm: *, cm: i) + hydrogen(h: *) = methyl_on_dimer(cm: H)
    forward_rate 4.5e13, 'cm3/(mol * s)'

  reaction 'methyl on dimer hydrogen migration'
    equation methyl_on_dimer(cl: *, cm: u, cm: H) = methyl_on_dimer(cm: *, cl: H)
    forward_activation 37.5
    forward_rate 2.1e12

  reaction 'migration down at activated dimer from methyl on bridge'
    aliases source: dimer, product: dimer
    equation methyl_on_bridge(cm: *, cm: u, cb: i) + source(cr: *) = product
    activation 0
    forward_rate 1e8

  reaction 'migration down at activated dimer from high bridge HH'
    aliases source: dimer, product: dimer
    equation high_bridge(ch: H, ch: H) + source(cr: *) = product(cr: *, cl: H)
    activation 0
    forward_rate 1e8
  reaction 'migration down at activated dimer from high bridge sH'
    aliases source: dimer, product: dimer
    equation high_bridge(ch: H, ch: *) + source(cr: *) = product(cr: *, cl: *)
    activation 0
    forward_rate 1e8

  reaction 'migration down in gap from methyl on bridge'
    equation methyl_on_bridge(cm: *, cm: *, cm: u, cb: i) + bridge(cr: *) + bridge(cr: *) = dimer_after_gap_b
    activation 0
    forward_rate 1e7

  reaction 'migration down in gap from high bridge'
    aliases source: dimer, product: dimer
    equation high_bridge(ch: *, ch: i) + bridge(cr: *) + bridge(cr: *) = dimer_after_gap_b(cl: *)
    activation 0
    forward_rate 1e7

  reaction 'migration through dimers row'
    equation methyl_on_dimer(cm: *, cm: u) + dimer(cr: *) = cross_bridge_on_dimers
    enthalpy 3.4
    activation 16 # is different: 30
    forward_rate 2.4e8

  reaction 'sierpinski drop'
    equation cross_bridge_on_bridges = methyl_on_bridge(cm: *, cm: u) + bridge(ct: *)
    activation 14
    forward_rate 4.4e9

  reaction 'surface activation'
    equation H + hydrogen(h: *) = * + hydrogen
    activation 6.65
    forward_rate 5.2e13, 'cm3/(mol * s)'

  reaction 'surface deactivation'
    equation * + hydrogen(h: *) = H
    activation 0
    forward_rate 2e13, 'cm3/(mol * s)'
