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
  atom_termination H
  total_time 1

gas
  spec :hydrogen
    atoms h: H # the second atom specifies by run::atom_termination

  spec :methan
    atoms c: C

#  spec :ethylene
#    atoms c1: C, c2: C
#    dbond :c1, :c2

  concentration hydrogen(h: *), 1e-9
  concentration methan(c: *), 1e-10
  # concentration ethylene(c1: *, c2: *), 0

  temperature 1200

surface
  lattice :d, cpp_class: Diamond

  spec :bridge
    atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl, face: 110
    bond :ct, :cr, face: 110
    position :cl, :cr, face: 100, dir: :front

  spec :high_bridge
    atoms ch: methan(:c), ct: bridge(:ct)
    dbond :ch, :ct

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_bridge
    aliases basis: bridge
    atoms cm: methan(:c), cb: basis(:ct), cl: basis(:cl), cr: basis(:cr)
    bond :cm, :cb

  spec :methyl_on_dimer
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

 # spec :vinyl_on_bridge
 #   atoms ct: ethylene(:c1), cb: bridge(:ct)
 #   bond :ct, :cb

 # spec :vinyl_on_dimer
 #   atoms cl: bridge(:ct), cr: vinyl_on_bridge(:cb)
 #   bond :cl, :cr, face: 100, dir: :front

  spec :bridge_with_dimer
    atoms ct: C%d, cl: bridge(:ct), cr: dimer(:cr)
    bond :ct, :cl, face: 110
    bond :ct, :cr, face: 110
    position :cl, :cr, face: 100, dir: :front

  spec :two_bridges
    atoms ctl: C%d, cl: bridge(:ct), cc: bridge(:cr)
    bond :ctl, :cl, face: 110
    bond :ctl, :cc, face: 110
    position :cl, :cc, face: 100, dir: :front

  spec :cross_bridge_on_dimers
    atoms ct: methan(:c), cl: dimer(:cr), cr: dimer(:cr)
    bond :ct, :cl
    bond :ct, :cr
    position :cl, :cr, face: 100, dir: :cross
    # TODO: не полностью уточнено положение димеров друг относительно друга, для данной структуры

  size x: 100, y: 100
  composition C%d
  temperature 1000

events
  reaction 'surface activation'
    equation H + hydrogen(h: *) == * + hydrogen
    activation 6.65
    forward_rate 5.2e13, 'cm3/(mol * s)'

  reaction 'surface deactivation'
    equation * + hydrogen(h: *) == H
    activation 0
    forward_rate 2e13, 'cm3/(mol * s)'

  reaction 'methyl adsorption to dimer'
    equation dimer(cr: *) + methan(c: *) == methyl_on_dimer
    entalpy -73.6
    activation 0
    forward_rate 1e13, 'cm3/(mol * s)'
    reverse_rate 5.3e3

  reaction 'methyl desorption'
    equation metyl_on_bridge == bridge(ct: *) + methan(c: *)
      refinement 'from bridge'
        incoherent methyl_on_bridge(:cb)
        forward_rate 1.7e7

      refinement 'from face 111'
        # должно быть автоматически определено, как случай не соответствующий всем другим
        forward_rate 5.4e6

    activation 0

  reaction 'methyl activation'
    equation metyl_on_dimer + hydrogen(h: *) == methyl_on_dimer(cm: *) + hydrogen
    activation 37.5
    forward_rate 2.8e8 * T ** 3.5, 'cm3/(mol * s)'

  reaction 'methyl deactivation'
    equation metyl_on_dimer(cm: *) + hydrogen(h: *) == methyl_on_dimer
    activation 0
    forward_rate 4.5e13, 'cm3/(mol * s)'

  reaction 'same methyl-dimer hydrogen migration'
    equation methyl_on_dimer(cm: *) == methyl_on_dimer(cl: *)
  #  entalpy -10
  #  activation 29.8
  #  forward_rate 4.6e6
  #  reverse_rate 6e4

    forward_activation 37.5
    forward_rate 2.1e12
    reverse_activation 50.5
    reverse_rate 1.2e12

  reaction 'methyl neighbour-dimer hydrogen migration'
    equation methyl_on_dimer + dimer(cr: *) == methyl_on_dimer(cm: *) + dimer
      refinement 'along chain'
        position methyl_on_dimer(:cr), dimer(:cr), face: 100, dir: :front
        forward_activation 16.3
        reverse_activation 25.1

      refinement 'along row'
        position methyl_on_dimer(:cr), dimer(:cr), face: 100, dir: :cross
        forward_activation 27.4
        reverse_activation 36.6

  #  entalpy -8.8
  #  activation 16.3
  #  forward_rate 1.8e9
  #  reverse_rate 1.3e8

    forward_rate 1.7e12
    reverse_rate 4.8e12

  reaction 'chain neighbour dimermethyl-fixedbridge hydrogen migration'
    equation methyl_on_dimer + bridge(cr: *) == methyl_on_dimer(cm: *) + bridge
      position methyl_on_dimer(:cr), bridge(:cr), face: 100, dir: :front

    activation 12.9
    forward_rate 7.4e9
    reverse_rate 1.1e11

  reaction 'chain neighbour bridgemethyl-fixedbridge hydrogen migration'
    equation methyl_on_bridge + bridge(cr: *) == methyl_on_bridge(cm: *) + bridge
      position methyl_on_bridge(:cb), bridge(:cr), face: 100, dir: :front
      incoherent methyl_on_bridge(:cb)

    activation 14.1
    forward_rate 4.5e9
    reverse_rate 2e12

  reaction 'chain neighbour bridge-fixedbridge hydrogen migration'
    equation bridge(cr: *) + bridge == bridge + bridge(ct: *)
      position bridge(:cr), bridge(:ct), face: 100, dir: :front
      incoherent bridge(:ct)

    activation 7
    forward_rate 6.6e10
    reverse_rate 1e10

  reaction 'chain neighbour bridge-dimer hydrogen migration'
    equation dimer(cr: *) + bridge == dimer + bridge(ct: *)
      position dimer(:cr), bridge(:ct), face: 100, dir: :front
      incoherent bridge(:ct)

    activation 23.6
    forward_rate 6.2e7
    reverse_rate 1.4e5

  reaction 'dimer hydrogen migration'
    equation dimer(cr: *) == dimer(cl: *)
    activation 51
    forward_rate 2.3e13

  shared_lateral :row_components do |one_atom, two_atom|
    aliases left: dimer, right: dimer

    lateral :end_row, 'at end of row'
      position one_atom, left(:cl), face: 100, dir: :cross
      position two_atom, left(:cr), face: 100, dir: :cross

    lateral :mid_row, 'in middle of row'
      use :end_row
      position one_atom, right(:cl), face: 100, dir: :cross
      position two_atom, right(:cr), face: 100, dir: :cross

  reaction 'dimer formation between incoherent bridges'
    aliases one: bridge, two: bridge
    # определение положения атомов выводится исходя из димера (результата реакции)?
    # думаю критично отличать прямую и обратную активации для этой реакции
    equation one(ct: *) + two(ct: *) == dimer
      incoherent one(:ct), two(:ct)
      lateral_like :row_components, one(:ct), two(:ct)

    entalpy -36, end_row: -39, mid_row: -43
    activation 0.8, end_row: 0.4, mid_row: 0
    forward_rate 8.9e11
    reverse_rate 2.2e6

  reaction 'dimer formation between incoherent bridge and fixed bridge'
    aliases one: bridge, two: bridge
    # см. коммент к предыдущей реакции
    equation one(ct: *) + two(cr: *) == dimer
      incoherent one(:ct)
      lateral_like :row_components, one(:ct), two(:cr)

    entalpy -29.4, end_row: -21.5, mid_row: -13.6
    activation 4, end_row: 2.7, mid_row: 0.7
    forward_rate 7.5e11
    reverse_rate 1.2e11

  shared_lateral :oppressive_methyl do |near_atom|
    lateral :near_methyl, 'when there is chain neighbour methyl'
      position near_atom, methyl_on_dimer(:cr), face: 100, dir: :front

  reaction 'methyl to high bridge'
    equation methyl_on_dimer(cm: *) == bridge(ct: *) + high_bridge
      position bridge(:ct), high_bridge(:ct), face: 100, dir: :front

      lateral_like :oppressive_methyl, methyl_on_dimer(:cr)
      lateral :near_hb, 'when there is chain neighbour high bridge'
        position methyl_on_dimer(:cr), high_bridge(:ct), face: 100, dir: :front

    # TODO: проверить соответствие значений направленности
    # TODO: энергии латеральных взаимодействий выдуманы
    forward_activation 15.3, near_methyl: 10.4, near_hb: 12
    forward_rate 9.8e12
    reverse_activation 2.9, near_methyl: 5.1, near_hb: 4.4
    reverse_rate 2.7e11

  reaction 'high bridge is stand to incoherent bridge'
    aliases source: bridge, result: bridge
    equation high_bridge + source(ct: *) == result(cr: *)
      incoherent source(:ct)
      position high_bridge(:ct), source(:ct), face: 100, dir: :front
      lateral_like :oppressive_methyl, high_bridge(:ct)

    # TODO: аналогично проверить значения
    entalpy 24
    forward_activation 36.3, near_methyl: 25.5
    forward_rate 6.1e13
    reverse_activation 12.3, near_methyl: 17.1
    reverse_rate 1.1e12

  reaction 'high bridge to bridge and dimer'
    # положение атомов также выводится исходя из результата реакции?
    equation high_bridge + dimer(cr: *) == bridge_with_dimer(cl: *)
      incoherent dimer(:cl)
      lateral_like :oppressive_methyl, high_bridge(:ct)

    # изначально было только одно значение энергии активации (для обоих направлений)
    forward_activation 14.9, near_methyl: 12.7
    forward_rate 2.2e9
    reverse_activation 14.9, near_methyl: 16.2
    reverse_rate 4.2e8

  reaction 'high bridge to two bridges on three'
    # конечное положение активной связи может быть не очевидно!
    equation high_bridge + bridge(cr: *) == two_bridges(cl: *)
      lateral_like :oppressive_methyl, high_bridge(:ct)

    # activation 3.2
    forward_activation 3.2, near_methyl: 0
    forward_rate 2.9e11
    reverse_activation 3.2, near_methyl: 5.3
    reverse_rate 1.1e8

  reaction 'migration along row'
    equation metyl_on_dimer(cm: *) + dimer(cr: *) == cross_bridge_on_dimers
    entalpy 3.4
    activation 30
    # значения скоростей выдуманы
    forward_rate 2.4e8
    reverse_rate 4.4e9

  reaction 'methyl to dimer'
    aliases source: dimer, result: dimer
    # указать какой конкретно атом начального димера становится атомом конечного димера?
    equation methyl_on_bridge(cm: *) + source(cr: *) == result
      incoherent methyl_on_bridge(:cb)
      position methyl_on_bridge(:cl), source(:cl), face: 100, dir: :cross
      position methyl_on_bridge(:cr), source(:cr), face: 100, dir: :cross

      # TODO: используются атомы результата!
      lateral_like :row_components, result(:cl), result(:cr)

    # все значения выдуманы
    activation 31.3, end_row: 17.6
    forward_rate 3.5e8

  # TODO: вмеру маленькой скорости, стоит исключить данную реакцию
  # reaction 'single dimer to high bridge'
  #   aliases one: bridge, two: bridge
  #   equation dimer == high_bridge + one(ct: *) + two(ct: *)
  #     # определяется ли положение атомов в веществах-продуктах?

  #     lateral :end_row, 'at end of row'
  #       # проблема с описанием "тех же атомов"
  #     end
  #   end

  #   # значения также выдуманы
  #   activation 53.5, end_row: :inf
  #   forward_rate 2.8e11
  # end

# Итого: 53 реакции
