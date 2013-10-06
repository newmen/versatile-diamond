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
  spec :methane
    atoms c: C

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

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_dimer
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

  temperature 1000

events
  reaction 'chain neighbour bridge-fixedbridge hydrogen migration'
    aliases left: bridge, right: bridge
    equation left(cr: *) + right = left + right(ct: *)
      position left(:cr), right(:ct), face: 100, dir: :front
      incoherent right(:ct)

    activation 7
    forward_rate 6.6e10
    reverse_rate 1e10

  reaction 'same methyl-dimer hydrogen migration'
    equation methyl_on_dimer(cm: *) = methyl_on_dimer(cl: *)
      unfixed methyl_on_dimer(:cm)

    forward_activation 37.5
    forward_rate 2.1e12
    reverse_activation 50.5
    reverse_rate 1.2e12

  reaction 'methyl neighbour-dimer hydrogen migration'
    equation methyl_on_dimer + dimer(cr: *) = methyl_on_dimer(cm: *) + dimer
      unfixed methyl_on_dimer(:cm)

      refinement 'along chain'
        position methyl_on_dimer(:cr), dimer(:cr), face: 100, dir: :front
        forward_activation 16.3
        reverse_activation 25.1

      refinement 'along row'
        position methyl_on_dimer(:cr), dimer(:cr), face: 100, dir: :cross
        forward_activation 27.4
        reverse_activation 36.6

    forward_rate 1.7e12
    reverse_rate 4.8e12
