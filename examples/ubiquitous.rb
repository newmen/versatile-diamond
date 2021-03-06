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

  spec :ethylene
    atoms c1: C, c2: C
    dbond :c1, :c2

  concentration hydrogen(h: *), 1e-10
  concentration methane(c: *), 1e-10
  concentration ethylene(c1: *), 1e-11
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

  spec :methyl_on_111
    atoms cm: methane(:c), cb: bridge(:cr)
    bond :cm, :cb

  spec :vinyl_on_111
    atoms c1: ethylene(:c1), cb: bridge(:cr)
    bond :c1, :cb

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_dimer
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

  size x: 100, y: 100, z: 5
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

  reaction 'methyl adsorption to bridge'
    equation bridge(ct: *, ct: i) + methane(c: *) = methyl_on_bridge
    activation 0
    reverse_rate 1.7e7

  reaction 'methyl adsorption to face 111'
    equation bridge(cr: *) + methane(c: *) = methyl_on_111
    activation 0
    reverse_rate 5.4e6

  reaction 'vinyl adsorption to 111'
    equation ethylene(c1: *) + bridge(cr: *) = vinyl_on_111
    activation 22.9
    forward_rate 6.9e7, 'cm3/(mol * s)'
    reverse_rate 1.7e9

  reaction 'methyl activation (changed for tests)'
    equation methyl_on_dimer(cm: u) + hydrogen(h: *) = methyl_on_dimer(cm: *) + hydrogen

    activation 37.5
    forward_rate 2.8e8 * T ** 3.5, 'cm3/(mol * s)'

  reaction 'methyl deactivation (changed for tests)'
    equation methyl_on_dimer(cm: *) + hydrogen(h: *) = methyl_on_dimer
      incoherent methyl_on_dimer(:cm)

    activation 0
    forward_rate 4.5e13, 'cm3/(mol * s)'
