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

  spec :methane
    atoms c: C # each external bond is H atom

  spec :ethylene
    atoms c1: C, c2: C
    dbond :c1, :c2

  spec :acetylene
    atoms c1: C, c2: C
    tbond :c1, :c2

  concentration hydrogen(h: *), 1e-9
  concentration methane(c: *), 1e-10
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

  spec :very_high_bridge
    aliases basis: high_bridge
    atoms c2: C, c1: basis(:ch), ct: basis(:ct)
    dbond :c1, :c2

  spec :dimer
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_bridge
    aliases basis: bridge
    atoms cm: methane(:c), cb: basis(:ct), cl: basis(:cl), cr: basis(:cr)
    bond :cm, :cb

  spec :methyl_on_dimer
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: 100, dir: :front

  spec :methyl_on_111
    atoms cm: C, cb: bridge(:cr)
    bond :cm, :cb

  spec :vinyl_on_111
    atoms c1: ethylene(:c1), cb: bridge(:cr)
    bond :c1, :cb

  spec :vinyl_on_bridge
    aliases eth: ethylene
    atoms cb: bridge(:ct), c1: eth(:c1), c2: eth(:c2)
    bond :cb, :c1

  spec :vinyl_on_dimer
    aliases vob: vinyl_on_bridge
    atoms cl: bridge(:ct), cr: vob(:cb), c1: vob(:c1), c2: vob(:c2)
    bond :cl, :cr, face: 100, dir: :front

  spec :bridge_with_dimer
    atoms ct: C%d, cl: bridge(:ct), cr: dimer(:cr)
    bond :ct, :cl, face: 110, dir: :cross
    bond :ct, :cr, face: 110, dir: :cross

  # более правильно было бы использовать :two_bridges
  spec :three_bridges
    atoms ctr: C%d, cbr: bridge(:ct), cc: bridge(:cr)
    bond :ctr, :cbr, face: 110, dir: :cross
    bond :ctr, :cc, face: 110, dir: :cross

  # более правильно было бы использовать :two_bridges
  spec :two_bridges_with_high_bridge
    aliases tbs: three_bridges
    atoms ch: C, ctr: tbs(:ctr), cbr: tbs(:cbr)
    dbond :ch, :ctr

  spec :cross_bridge_on_dimers
    atoms ct: C, cl: dimer(:cr), cr: dimer(:cr)
    bond :ct, :cl
    bond :ct, :cr
    position :cl, :cr, face: 100, dir: :cross
    # TODO: не полностью уточнено положение димеров друг относительно друга, для данной структуры
    # полезно использовать not

  size x: 100, y: 100, z: 5
  composition C%d # TODO: ??
  temperature 1000

events
  reaction 'surface activation'
    equation H + hydrogen(h: *) = * + hydrogen
    activation 6.65
    forward_rate 5.2e13, 'cm3/(mol * s)'

  reaction 'surface deactivation'
    equation * + hydrogen(h: *) = H
    activation 6.31
    forward_rate 2e13, 'cm3/(mol * s)'

  reaction 'methyl adsorption to dimer'
    equation dimer(cr: *) + methane(c: *) = methyl_on_dimer
    enthalpy -73.6
    # by default activation = 0
    forward_rate 1e13, 'cm3/(mol * s)'
    reverse_rate 5.3e3

  reaction 'methyl adsorption to bridge'
    equation bridge(ct: *, ct: i) + methane(c: *) = methyl_on_bridge
    reverse_rate 1.7e7

  reaction 'methyl adsorption to face 111'
    equation bridge(cr: *) + methane(c: *) = methyl_on_111
    forward_rate 1.2e-1, 'cm3/(mol * s)'
    reverse_rate 5.4e6

  reaction 'methyl activation'
    # TODO: может быть следует использовать methyl_on_bridge?
    # TODO: можно автоматом узнавать, что :cm атом в methyl_on_dimer должен иметь H
    equation methyl_on_dimer(cm: H) + hydrogen(h: *) = methyl_on_dimer(cm: *) + hydrogen
      unfixed methyl_on_dimer(:cm)

    activation 5.2
    forward_rate 2.8e2, 'cm3/(mol * s)'
    forward_tpow 3.5

  reaction 'methyl deactivation'
    equation methyl_on_dimer(cm: *) + hydrogen(h: *) = methyl_on_dimer(cm: H)
      unfixed methyl_on_dimer(:cm)

    forward_rate 4.5e13, 'cm3/(mol * s)'

  reaction 'hydrogen abstraction from gap'
    aliases one: bridge, two: bridge
    # TODO: возможно стоит скрыть от пользователя возможность определения необходимости наличия одновалентных атомов, и определять это автоматически. Можно сделать условия более мягкими, и для случая, если пользователь указать "cr: i", то автоматически определять по правой части уравнения, что должно быть "cr: H".
    equation one(cr: H) + two(cr: H) = one(cr: *) + two(cr: *) + hydrogen
      position one(:cr), two(:cr), face: 100, dir: :front

    activation 35
    forward_rate 3e6 # TODO: maybe value more grater than presented

  reaction 'same methyl-dimer hydrogen migration'
    equation methyl_on_dimer(cl: *, cm: H) = methyl_on_dimer(cm: *, cl: H)
      unfixed methyl_on_dimer(:cm)

  #  enthalpy -10
  #  activation 29.8
  #  forward_rate 4.6e6
  #  reverse_rate 6e4

    forward_activation 37.5
    forward_rate 2.1e12
    reverse_activation 50.5
    reverse_rate 1.2e12

  reaction 'methyl neighbour-dimer hydrogen migration'
    equation methyl_on_dimer(cm: H) + dimer(cr: *) = methyl_on_dimer(cm: *) + dimer(cr: H)
      unfixed methyl_on_dimer(:cm)

      refinement 'along chain'
        position methyl_on_dimer(:cr), dimer(:cr), face: 100, dir: :front
        forward_activation 16.3
        reverse_activation 25.1

      refinement 'along row'
        position methyl_on_dimer(:cr), dimer(:cr), face: 100, dir: :cross
        forward_activation 27.4
        reverse_activation 36.6

  #  enthalpy -8.8
  #  activation 16.3
  #  forward_rate 1.8e9
  #  reverse_rate 1.3e8

    forward_rate 1.7e12
    reverse_rate 4.8e12

  reaction 'chain neighbour dimermethyl-fixedbridge hydrogen migration'
    equation methyl_on_dimer(cm: H) + bridge(cr: *) = methyl_on_dimer(cm: *) + bridge(cr: H)
      unfixed methyl_on_dimer(:cm)
      position methyl_on_dimer(:cr), bridge(:cr), face: 100, dir: :front

    activation 12.9
    forward_rate 7.4e9
    reverse_rate 1.1e11

  reaction 'chain neighbour bridgemethyl-fixedbridge hydrogen migration'
    equation methyl_on_bridge(cm: H) + bridge(cr: *) = methyl_on_bridge(cm: *) + bridge(ct: H)
      unfixed methyl_on_bridge(:cm)
      incoherent methyl_on_bridge(:cb)
      position methyl_on_bridge(:cb), bridge(:cr), face: 100, dir: :front

    activation 14.1
    forward_rate 4.5e9
    reverse_rate 2e12

  reaction 'chain neighbour bridge-fixedbridge hydrogen migration'
    aliases left: bridge, right: bridge
    equation left(cr: *) + right(ct: H) = left(cr: H) + right(ct: *)
      position left(:cr), right(:ct), face: 100, dir: :front
      incoherent right(:ct)

    activation 7
    forward_rate 6.6e10
    reverse_rate 1e10

  reaction 'chain neighbour bridge-dimer hydrogen migration'
    equation dimer(cr: *) + bridge(ct: H) = dimer(cr: H) + bridge(ct: *)
      position dimer(:cr), bridge(:ct), face: 100, dir: :front
      incoherent bridge(:ct)

    activation 23.6
    forward_rate 6.2e7
    reverse_rate 1.4e5

  reaction 'dimer hydrogen migration'
    equation dimer(cr: *, cl: H) = dimer(cl: *, cr: H)
    activation 51
    forward_rate 2.3e13

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

      lateral :dimers_row, one_atom: one(:ct), two_atom: two(:ct)

      there :end_row
        enthalpy -39
        reverse_activation 1

      there :mid_row
        enthalpy -43
        reverse_activation 1.2

    forward_rate 8.9e11
    reverse_rate 2.2e6

  reaction 'dimer formation between incoherent bridge and fixed bridge'
    aliases one: bridge, two: bridge
    equation one(ct: *, ct: i) + two(cr: *) = bridge_with_dimer

      refinement 'not in dimers row'
        enthalpy -29.4
        activation 4

      lateral :dimers_row, one_atom: one(:ct), two_atom: two(:cr)

      there :mid_row
        enthalpy -13.6
        reverse_activation 4.2

      there :end_row
        enthalpy -21.5
        forward_activation 2.7
        reverse_activation 4.1

    forward_rate 7.5e11
    reverse_rate 1.2e11

  environment :high_neighbour
    targets :target_atom

    where :near_methyl, 'when there is chain neighbour methyl'
      position target_atom, methyl_on_dimer(:cr), face: 100, dir: :front

    # TODO: этот случай используется не везде
    where :near_high_bridge, 'when there is chain neighbour high bridge'
      position target_atom, high_bridge(:ct), face: 100, dir: :front


  reaction 'methyl to high bridge'
    # TODO: проверить соответствие значений направленности
    equation methyl_on_dimer(cm: *, cm: u) = bridge(ct: *, ct: i) + high_bridge
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
    equation high_bridge(ch: i) + source(ct: *, ct: i) = product(cr: *)

      refinement 'without chain neighbour methyl'
        forward_activation 12.3
        reverse_activation 36.3

      # TODO: аналогично проверить значения
      lateral :high_neighbour, target_atom: high_bridge(:ct)
      there :near_methyl
        forward_activation 17.1
        reverse_activation 25.5

    enthalpy 24
    forward_rate 1.1e12
    reverse_rate 6.1e13

  reaction 'high bridge to bridge and dimer'
    equation high_bridge(ch: i) + dimer(cr: *, cl: i) = bridge_with_dimer(cl: *)

      refinement 'without chain neighbour methyl'
        activation 14.9

      lateral :high_neighbour, target_atom: high_bridge(:ct)
      there :near_methyl
        forward_activation 12.7
        reverse_activation 16.2

    forward_rate 2.2e9
    reverse_rate 4.2e8

  reaction 'high bridge to two bridges on three'
    equation high_bridge(ch: i) + bridge(cr: *) = three_bridges(cbr: *)
      refinement 'without chain neighbour methyl'
        activation 3.2
        forward_rate 2.9e11

      lateral :high_neighbour, target_atom: high_bridge(:ct)
      there :near_methyl
        forward_activation 999 # deny
        reverse_activation 5.3

    reverse_rate 1.1e8

  reaction 'migration along row'
    equation methyl_on_dimer(cm: *, cm: u) + dimer(cr: *) = cross_bridge_on_dimers

    enthalpy 3.4
    activation 14.1
    # значения скоростей выдуманы
    forward_rate 2.4e8
    reverse_rate 4.4e9

  environment :dimers_edge
    targets :one_atom, :two_atom
    aliases dm: dimer

    where :edge, 'at end of dimers edge'
      position one_atom, dm(:cl), face: 100, dir: :cross
      position two_atom, dm(:cr), face: 110, dir: :front

  reaction 'methyl to dimer (incorporate down at 100 face)'
    aliases source: dimer, product: dimer
    equation methyl_on_bridge(cm: *, cm: u, cb: i) + source(cr: *) = product

      # все значения выдуманы
      refinement 'not in dimers row'
        forward_activation 31.3

      lateral :dimers_edge, one_atom: methyl_on_bridge(:cb), two_atom: source(:cl)
      there :edge
        forward_activation 17.6 # must be more less

    forward_rate 3.5e8

  # TODO: вмеру маленькой (??) скорости, стоит исключить данную реакцию
  reaction 'single dimer to high bridge'
    aliases one: bridge, two: bridge
    equation dimer(cr: *) = high_bridge(ch: *) + one(ct: *) + two(ct: *)

      refinement 'not in dimers row'
        forward_activation 53.5

      lateral :dimers_row, one_atom: dimer(:cr), two_atom: dimer(:cl)
      there :end_row
        forward_activation 999 # deny

    # значения также выдуманы
    forward_rate 2.8e11

  # TODO: реакции с ацетиленом следовало бы вынести в отдельный файл и предоставить возможность подключения этого другого файла
  reaction 'vinyl adsorption to dimer'
    equation ethylene(c1: *) + dimer(cr: *) = vinyl_on_dimer
    activation 8.4
    forward_rate 2.4e11, 'cm3/(mol * s)'
    reverse_rate 1.3e2 # 1.4e7 - это значение под большим вопросом, должно быть меньше?

  reaction 'vinyl adsorption to 111'
    equation ethylene(c1: *) + bridge(cr: *) = vinyl_on_111
    activation 22.9
    forward_rate 6.9e7, 'cm3/(mol * s)'
    reverse_rate 1.7e9 # тоже самое что и предыдущее?

  reaction 'vinyl adsorption to bridge'
    equation ethylene(c1: *) + bridge(ct: *, ct: i) = vinyl_on_bridge
    activation 26
    forward_rate 1.9e7, 'cm3/(mol * s)'
    reverse_rate 4.1e9 # тоже самое что и предыдущее?

  reaction 'vinyl desorption'
    equation vinyl_on_bridge(c1: *, c2: *) = bridge(ct: *) + acetylene(c1: *)
    forward_rate 1.3e2

  reaction 'vinyl activation'
    # TODO: есть ещё активация атома c2
    equation vinyl_on_dimer(c1: H) + hydrogen(h: *) = vinyl_on_dimer(c1: *) + hydrogen
    forward_rate 0.6e13, 'cm3/(mol * s)'

  reaction 'vinyl hydrogen migration'
    equation vinyl_on_dimer(cl: *) = vinyl_on_dimer(c1: *)
    activation 33.4
    forward_rate 1.2e6
    reverse_rate 1.2e5

  reaction 'vinyl neighbour dimer hydrogen migration'
    equation dimer(cr: *) + vinyl_on_dimer(c1: H) = vinyl_on_dimer(c1: *) + dimer(cr: H)
      refinement 'in chain'
        position dimer(:cr), vinyl_on_dimer(:cr), face: 100, dir: :front
        activation 33.4
        forward_rate 1.2e6
        reverse_rate 1.2e5

      refinement 'in row'
        position dimer(:cr), vinyl_on_dimer(:cr), face: 100, dir: :cross
        activation 20.3
        forward_rate 2.8e8
        reverse_rate 3e7

  # TODO: все значения для преобразования винила – выдуманы!
  reaction 'vinyl to very high bridge'
    equation vinyl_on_dimer(c1: *, c2: i) = very_high_bridge + bridge(ct: *)
    forward_activation 20.1
    reverse_activation 5.9
    forward_rate 9.4e12
    reverse_rate 8.1e10

  reaction 'very high bridge stand to incoherent bridge'
    equation very_high_bridge(c2: i) + bridge(ct: *, ct: i) = high_bridge(cr: *)
    forward_activation 18.4
    reverse_activation 37.5
    forward_rate 9.7e11
    reverse_rate 1.1e13

  reaction 'very high bridge stand to fixed bridge'
    equation very_high_bridge(c2: i) + bridge(cr: *) = two_bridges_with_high_bridge(cbr: *)
    forward_activation 10.9
    reverse_activation 32.2
    forward_rate 1.5e11
    reverse_rate 5.2e7
