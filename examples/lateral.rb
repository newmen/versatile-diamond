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
  lattice :d, cpp_class: Diamond

  spec :bridge
    atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl, face: 110, dir: :front
    bond :ct, :cr, face: 110, dir: :front
    position :cl, :cr, face: 100, dir: :front

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

  temperature 1000

events
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
    # TODO: определение положения атомов выводится исходя из результата реакции?
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

  environment :high_neighbour
    targets :target_atom

    where :near_methyl, 'when there is chain neighbour methyl'
      position target_atom, methyl_on_dimer(:cr), face: 100, dir: :front

    # TODO: этот случай используется не везде
    where :near_high_bridge, 'when there is chain neighbour high bridge'
      position target_atom, high_bridge(:ct), face: 100, dir: :front


  reaction 'methyl to high bridge'
    # TODO: проверить соответствие значений направленности
    equation methyl_on_dimer(cm: *) = bridge(ct: *) + high_bridge
      unfixed methyl_on_dimer(:cm)
      position bridge(:ct), high_bridge(:ct), face: 100, dir: :front # TODO: должно быть определено автоматически, по соответствию в графах

      refinement 'without high chain neighbour'
        forward_activation 15.3
        reverse_activation 2.9

      lateral :high_neighbour, target_atom: methyl_on_dimer(:cr)

      # TODO: энергии латеральных взаимодействий выдуманы (как, впорочем, и ранее)
      there :near_methyl
        forward_activation 10.4
        reverse_activation 5.1

      there :near_high_bridge
        forward_activation 12
        reverse_activation 4.4

    forward_rate 9.8e12
    reverse_rate 2.7e11

  reaction 'high bridge is stand to incoherent bridge'
    aliases source: bridge, product: bridge
    equation high_bridge + source(ct: *, ct: i) = product(cr: *)
      position high_bridge(:ct), source(:ct), face: 100, dir: :front

      refinement 'without chain neighbour methyl'
        forward_activation 36.3
        reverse_activation 12.3

      # TODO: аналогично проверить значения
      lateral :high_neighbour, target_atom: high_bridge(:ct)
      there :near_methyl
        forward_activation 25.5
        reverse_activation 17.1

    enthalpy 24
    forward_rate 6.1e13
    reverse_rate 1.1e12
