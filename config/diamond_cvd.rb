elements do
  # atom H, valence: 1 # already exists
  atom C, valence: 4
end

gas do
  # spec :hydrogen # already exists
  spec :methan do
    atoms c: C
  end

#  spec :ethylene do
#    atoms c1: C, c2: C
#    dbond :c1, :c2
#  end
end

surface do
  phases do
    phase :d, class: Diamond
  end

  spec :bridge do
    atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl, face: '110'
    bond :ct, :cr, face: '110'
    position :cl, :cr, face: '100', dir: :front
  end

  spec :high_bridge do
    atoms ch: methan(:c), ct: bridge(:ct)
    dbond :ch, :ct
  end

  spec :dimer do
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: '100', dir: :front
  end

  spec :methyl_on_bridge do
    aliases basis: bridge
    atoms cm: methan(:c), cb: basis(:ct), cl: basis(:cl), cr: basis(:cr)
    bond :cm, :cb
  end

  spec :methyl_on_dimer do
    aliases mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: '100', dir: :front
  end

 # spec :vinyl_on_bridge do
 #   atoms ct: ethylene(:c1), cb: bridge(:ct)
 #   bond :ct, :cb
 # end

 # spec :vinyl_on_dimer do
 #   atoms cl: bridge(:ct), cr: vinyl_on_bridge(:cb)
 #   bond :cl, :cr, face: '100', dir: :front
 # end

  spec :bridge_with_dimer do
    atoms ct: C%d, cl: bridge(:ct), cr: dimer(:cr)
    bond :ct, :cl, face: '110'
    bond :ct, :cr, face: '110'
    position :cl, :cr, face: '100', dir: :front
  end

  spec :two_bridges do
    atoms ctl: C%d, cl: bridge(:ct), cc: bridge(:cr)
    bond :ctl, :cl, face: '110'
    bond :ctl, :cc, face: '110'
    position :cl, :cc, face: '100', dir: :front
  end

  spec :cross_bridge_on_dimers do
    atoms ct: methan(:c), cl: dimer(:cl), cr: dimer(:cl)
    bond :ct, :cl
    bond :ct, :cr
    position :cl, :cr, face: '100', dir: :cross
    # TODO: не полностью уточнено положение димеров друг относительно друга, для данной структуры
  end
end

dimensions do
  temperature 'K'
  concentration 'mol/cm3'
  energy 'kcal/mol'
  rate '1/s'
  time 's'
end

run do
  surface do
    lattice C%d
    termination H
    area_size 100, 100
    temperature 1000
  end

  gas do
    concentration hydrogen(:*), 1e-9
    concentration methan(:*), 1e-10
    # concentration ethylene(c1: :*, c2: :*), 0
    temperature 1200
  end

  total_time 1
end

reaction 'surface activation' do
  equation H + hydrogen(:*) == :* + hydrogen
  activation 6.65
  forward_rate 5.2e13, 'cm3/(mol * s)'
end

reaction 'surface deactivation' do
  equation :* + hydrogen(:*) == H
  activation 0
  forward_rate 2e13, 'cm3/(mol * s)'
end

reaction 'methyl adsorption to dimer' do
  equation dimer(cr: :*) + methan(:*) == methyl_on_dimer
  entalpy -73.6
  activation 0
  forward_rate 1e13, 'cm3/(mol * s)'
  reverse_rate 5.3e3
end

reaction 'methyl desorption' do
  equation metyl_on_bridge == bridge(ct: :*) + methan(:*) do
    refinement 'from bridge' do
      incoherent methyl_on_bridge(:cb)
      forward_rate 1.7e7
    end

    refinement 'from face 111' do
      # должно быть автоматически определено, как случай не соответствующий всем другим
      forward_rate 5.4e6
    end
  end

  activation 0
end

reaction 'methyl activation' do
  equation metyl_on_dimer + hydrogen(:*) == methyl_on_dimer(cm: :*) + hydrogen
  activation 37.5
  forward_rate 2.8e8 * T ** 3.5, 'cm3/(mol * s)'
end

reaction 'methyl deactivation' do
  equation metyl_on_dimer(cm: :*) + hydrogen(:*) == methyl_on_dimer
  activation 0
  forward_rate 4.5e13, 'cm3/(mol * s)'
end

reaction 'same methyl-dimer hydrogen migration' do
  equation methyl_on_dimer(cm: :*) == methyl_on_dimer(cl: :*)
#  entalpy -10
#  activation 29.8
#  forward_rate 4.6e6
#  reverse_rate 6e4

  forward_activation 37.5
  forward_rate 2.1e12
  reverse_activation 50.5
  reverse_rate 1.2e12
end

reaction 'methyl neighbour-dimer hydrogen migration' do
  equation methyl_on_dimer + dimer(cr: :*) == methyl_on_dimer(cm: :*) + dimer do
    refinement 'along chain' do
      position methyl_on_dimer(:cr), dimer(:cr), face: '100', dir: :front
      forward_activation 16.3
      reverse_activation 25.1
    end

    refinement 'along row' do
      position methyl_on_dimer(:cr), dimer(:cr), face: '100', dir: :cross
      forward_activation 27.4
      reverse_activation 36.6
    end
  end

#  entalpy -8.8
#  activation 16.3
#  forward_rate 1.8e9
#  reverse_rate 1.3e8

  forward_rate 1.7e12
  reverse_rate 4.8e12
end

reaction 'chain neighbour dimermethyl-fixedbridge hydrogen migration' do
  equation methyl_on_dimer + bridge(cr: :*) == methyl_on_dimer(cm: :*) + bridge do
    position methyl_on_dimer(:cr), bridge(:cr), face: '100', dir: :front
  end

  activation 12.9
  forward_rate 7.4e9
  reverse_rate 1.1e11
end

reaction 'chain neighbour bridgemethyl-fixedbridge hydrogen migration' do
  equation methyl_on_bridge + bridge(cr: :*) == methyl_on_bridge(cm: :*) + bridge do
    position methyl_on_bridge(:cb), bridge(:cr), face: '100', dir: :front
    incoherent methyl_on_bridge(:cb)
  end

  activation 14.1
  forward_rate 4.5e9
  reverse_rate 2e12
end

reaction 'chain neighbour bridge-fixedbridge hydrogen migration' do
  equation bridge(cr: :*) + bridge == bridge + bridge(ct: :*) do
    position bridge(:cr), bridge(:ct), face: '100', dir: :front
    incoherent bridge(:ct)
  end

  activation 7
  forward_rate 6.6e10
  reverse_rate 1e10
end

reaction 'chain neighbour bridge-dimer hydrogen migration' do
  equation dimer(cr: :*) + bridge == dimer + bridge(ct: :*) do
    position dimer(:cr), bridge(:ct), face: '100', dir: :front
    incoherent bridge(:ct)
  end

  activation 23.6
  forward_rate 6.2e7
  reverse_rate 1.4e5
end

reaction 'dimer hydrogen migration' do
  equation dimer(cr: :*) == dimer(cl: :*)
  activation 51
  forward_rate 2.3e13
end

reaction 'dimer formation' do
  aliases one: bridge, two: bridge, left: dimer, right: dimer
  # определение положения атомов выводится исходя из димера (результата реакции)?
  # думаю критично отличать прямую и обратную активации для этой реакции
  equation one(ct: :*) + two(ct: :*) == dimer do
    refinement 'between incoherent bridges' do
      incoherent one(:ct), two(:ct)
      entalpy -36, end_row: -39, mid_row: -43
      activation 0.8, end_row: 0.4, mid_row: 0
      forward_rate 8.9e11
      reverse_rate 2.2e6
    end

    refinement 'between incoherent bridge and fixed bridge' do
      incoherent one(:ct)
      entalpy -29.4, end_row: -21.5, mid_row: -13.6
      activation 4, end_row: 2.7, mid_row: 0.7
      forward_rate 7.5e11
      reverse_rate 1.2e11
    end

    lateral :end_row, 'at end of row' do
      position one(:ct), left(:cl), face: '100', dir: :cross
      position two(:ct), left(:cr), face: '100', dir: :cross
    end

    lateral :mid_row, 'in middle of row' do
      use :end_row
      position one(:ct), right(:cl), face: '100', dir: :cross
      position two(:ct), right(:cr), face: '100', dir: :cross
    end
  end
end

reaction 'methyl to high bridge' do
  equation methyl_on_dimer(cm: :*) == bridge(ct: :*) + high_bridge do
    position bridge(:ct), high_bridge(:ct), face: '100', dir: :front

    lateral :near_methyl, 'when there is chain neighbour methyl' do
      position methyl_on_dimer(:cr), methyl_on_bridge(:cb), face: '100', dir: :front
    end

    lateral :near_hb, 'when there is chain neighbour high bridge' do
      position methyl_on_dimer(:cr), high_bridge(:ct), face: '100', dir: :front
    end
  end

  # TODO: проверить соответствие значений направленности
  # TODO: энергии латеральных взаимодействий выдуманы
  forward_activation 15.3, near_methyl: 10.4, near_hb: 12
  forward_rate 9.8e12
  reverse_activation 2.9, near_methyl: 5.1, near_hb: 4.4
  reverse_rate 2.7e11
end

reaction 'high bridge is stand to incoherent bridge' do
  aliases source: bridge, result: bridge
  equation high_bridge + source(ct: :*) == result(cr: :*) do
    incoherent source(:ct)
    position high_bridge(:ct), source(:ct), face: '100', dir: :front

    # TODO: в этой и двух последующих реакциях используется одно и тоже определение лательного взаимодействия
    lateral :near_methyl, 'when there is chain neighbour methyl' do
      position high_bridge(:ct), methyl_on_bridge(:cb), face: '100', dir: :front
    end
  end

  # TODO: аналогично проверить значения
  entalpy 24
  forward_activation 36.3, near_methyl: 25.5
  forward_rate 6.1e13
  reverse_activation 12.3, near_methyl: 17.1
  reverse_rate 1.1e12
end

reaction 'high bridge to bridge and dimer' do
  # положение атомов также выводится исходя из результата реакции?
  equation high_bridge + dimer(cr: :*) == bridge_with_dimer(cl: :*) do
    incoherent dimer(:cl)

    lateral :near_methyl, 'when there is chain neighbour methyl' do
      position high_bridge(:ct), methyl_on_bridge(:cb), face: '100', dir: :front
    end
  end

  # изначально было только одно значение энергии активации (для обоих направлений)
  forward_activation 14.9, near_methyl: 12.7
  forward_rate 2.2e9
  reverse_activation 14.9, near_methyl: 16.2
  reverse_rate 4.2e8
end

reaction 'high bridge to two bridges on three' do
  # конечное положение активной связи может быть не очевидно!
  equation high_bridge + bridge(cr: :*) == two_bridges(cl: :*) do
    lateral :near_methyl, 'when there is chain neighbour methyl' do
      position high_bridge(:ct), methyl_on_bridge(:cb), face: '100', dir: :front
    end
  end

  # activation 3.2
  forward_activation 3.2, near_methyl: 0
  forward_rate 2.9e11
  reverse_activation 3.2, near_methyl: 5.3
  reverse_rate 1.1e8
end

reaction 'migration along row' do
  equation metyl_on_dimer(cm: :*) + dimer(cr: :*) == cross_bridge_on_dimers
  entalpy 3.4
  activation 30
  # значения скоростей выдуманы
  forward_rate 2.4e8
  reverse_rate 4.4e9
end

reaction 'methyl to dimer' do
  aliases source: dimer, result: dimer
  # указать какой конкретно атом начального димера становится атомом конечного димера?
  equation methyl_on_bridge(cm: :*) + source(cr: :*) == result do
    incoherent methyl_on_bridge(:cb)
    position methyl_on_bridge(:cl), source(:cl), face: '100', dir: :cross
    position methyl_on_bridge(:cr), source(:cr), face: '100', dir: :cross

    lateral :end_row, 'at end of row' do
      # проблема с описанием "тех же атомов"
    end
  end

  # все значения выдуманы
  activation 31.3, end_row: 17.6
  forward_rate 3.5e8
end

# TODO: вмеру маленькой скорости, стоит исключить данную реакцию
# reaction 'single dimer to high bridge' do
#   aliases one: bridge, two: bridge
#   equation dimer == high_bridge + one(ct: :*) + two(ct: :*) do
#     # определяется ли положение атомов в веществах-продуктах?

#     lateral :end_row, 'at end of row' do
#       # проблема с описанием "тех же атомов"
#     end
#   end

#   # значения также выдуманы
#   activation 53.5, end_row: :inf
#   forward_rate 2.8e11
# end

# Итого: 53 реакции
