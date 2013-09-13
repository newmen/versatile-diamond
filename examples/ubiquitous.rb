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

  concentration hydrogen(h: *), 1e-10
  concentration methane(c: *), 1e-10
  temperature 1200

surface
  lattice :d, class: Diamond

  spec :bridge
    atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl, face: 110, dir: :cross
    bond :ct, :cr, face: 110, dir: :cross
    position :cl, :cr, face: 100, dir: :front

  spec :methyl_on_bridge
    aliases basis: bridge
    atoms cm: methane(:c), cb: basis(:ct), cl: basis(:cl), cr: basis(:cr)
    bond :cm, :cb

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_dimer
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

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

  reaction 'methyl desorption'
    equation methyl_on_bridge = bridge(ct: *) + methane(c: *)
      refinement 'from bridge'
        incoherent methyl_on_bridge(:cb) # indicates automaticaly by methane
        forward_rate 1.7e7

      refinement 'from face 111'
        # TODO: должно быть автоматически определено, как случай не соответствующий всем другим
        forward_rate 5.4e6

    activation 0

  reaction 'methyl activation'
    # TODO: должна быть уточнением реакции десорбции водорода
    # TODO: может быть следует использовать methyl_on_bridge?
    equation methyl_on_dimer + hydrogen(h: *) = methyl_on_dimer(cm: *) + hydrogen
      incoherent methyl_on_dimer(:cm)
      unfixed methyl_on_dimer(:cm)

    activation 37.5
    forward_rate 2.8e8 * T ** 3.5, 'cm3/(mol * s)'

  reaction 'methyl deactivation'
    equation methyl_on_dimer(cm: *) + hydrogen(h: *) = methyl_on_dimer
      incoherent methyl_on_dimer(:cm)
      unfixed methyl_on_dimer(:cm)

    activation 0
    forward_rate 4.5e13, 'cm3/(mol * s)'
