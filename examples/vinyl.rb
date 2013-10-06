elements
  atom H, valence: 1
  atom C, valence: 4

dimensions
  temperature 'K'
  concentration 'mol/cm3'
  energy 'kcal/mol'
  rate '1/s'
  time 's'

run
  total_time 1

gas
  spec :hydrogen
    atoms h: H # the second atom is H too by default

  spec :ethylene
    atoms c1: C, c2: C
    dbond :c1, :c2

  spec :acetylene
    atoms c1: C, c2: C
    tbond :c1, :c2

  concentration hydrogen(h: *), 1e-9
  concentration ethylene(c1: *), 1e-11

  temperature 1200

surface
  lattice :d, class: Diamond

  spec :bridge
    atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl, face: 110, dir: :cross
    bond :ct, :cr, face: 110, dir: :cross

  spec :high_bridge
    aliases basis: bridge
    atoms ch: C, ct: basis(:ct), cr: basis(:cr)
    dbond :ch, :ct

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :vinyl_on_bridge
    aliases eth: ethylene
    atoms cb: bridge(:ct), c1: eth(:c1), c2: eth(:c2)
    bond :cb, :c1

  spec :vinyl_on_dimer
    aliases vob: vinyl_on_bridge
    atoms cl: bridge(:ct), cr: vob(:cb), c1: vob(:c1)
    bond :cl, :cr, face: 100, dir: :front

  temperature 1000

events
  reaction 'vinyl adsorption to dimer'
    equation ethylene(c1: *) + dimer(cr: *) = vinyl_on_dimer
    activation 55
    forward_rate 1, 'cm3/(mol * s)'
    reverse_rate 2

  reaction 'vinyl adsorption to bridge'
    equation ethylene(c1: *) + bridge(ct: *, ct: i) = vinyl_on_bridge
    activation 55
    forward_rate 1, 'cm3/(mol * s)'
    reverse_rate 2

  reaction 'vinyl desorption'
    equation vinyl_on_bridge(c1: *, c2: *) = bridge(ct: *) + acetylene(c1: *)
    activation 55
    forward_rate 1

  reaction 'vinyl incorporion'
    equation vinyl_on_dimer(c1: *) = high_bridge(cr: *)
    activation 55
    forward_rate 1
    reverse_rate 2
