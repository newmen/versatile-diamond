atoms do
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
    atoms ct: C%d, cl: C%d, cr: C%d
    bond :ct, :cl, face: :110
    bond :ct, :cr, face: :110
    pos :cl, :cr, face: :100, dir: :front
  end

  spec :high_bridge do
    atoms ch: C, ct: bridge(:ct)
    dbond :ch, :ct
  end

  spec :dimer do
    atoms cl: bridge(:ct), cr: bridge(:ct)
    bond :cl, :cr, face: :100, dir: :front
  end

  spec :methyl_on_bridge do
    atoms cm: C, cb: bridge(:ct)
    bond :cm, :cb
  end

  spec :methyl_on_dimer do
    refs mb: methyl_on_bridge
    atoms cl: bridge(:ct), cr: mb(:cb), cm: mb(:cm)
    bond :cl, :cr, face: :100, dir: :front
  end

  spec :bridge_and_dimer do
    atoms cl: bridge(:ct), cr: bridge(:cr)
    bond :cl, :cr, face: :100, dir: :front
  end

#  spec :acetyl_on_bridge do
#    atoms cat: C, cab: C, cb: bridge(:ct)
#    dbond :cat, :cab
#    bond :cab, :cb
#  end

#  spec :acetyl_on_dimer do
#    atoms cl: bridge(:ct), cr: acetyl_on_bridge(:cb)
#    bond :cl, :cr, face: :100, dir: :front
#  end

  spec :bridge_on_bridges do
    atoms ct: C%d, cl: bridge(:ct), cr: bridge(:ct)
    bond :ct, :cl, face: :110
    bond :ct, :cr, face: :110
    pos :cl, :cr, face: :100, dir: :front
  end

  # TODO: всё что ниже, пока не используется
  spec :cross_bridge_on_dimers do
    atoms ct: C, cl: dimer(:cl), cr: dimer(:cl)
    bond :ct, :cl
    bond :ct, :cr
    pos :cl, :cr, face: :100, dir: :cross
  end

  spec :methyl_on_bb do
    atoms cm: C, ct: bridge_on_bridges(:ct)
    bond :cm, :ct
  end

  spec :dimer_on_bridges do
    atoms cl: bridge_on_bridges(:ct), cr: bridge_on_bridges(:ct)
    bond :cl, :ct, face: :100, dir: :front
  end

  spec :high_bridge_on_bridges do
    atoms ch: C, ct: bridge_on_bridges(:ct)
    dbond :ch, :ct
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
  default_termination H

  surface do
    lattice C%d
    area_size 100, 100
    slices 2
  end

  temperature 1200
  concentration hydrogen(:*), 1e-9
  concentration methan(:*), 1e-10
#  concentration ethylene(c1: :*, c2: :*), 0

  total_time 1
end

reaction 'surface activation' do
  it H + hydrogen(:*) == :* + hydrogen
  activation 6.65
  forward_rate 5.2e13, 'cm3/(mol * s)'
end

reaction 'surface deactivation' do
  it :* + hydrogen(:*) == H
  activation 0
  forward_rate 2e13, 'cm3/(mol * s)'
end

reaction 'methyl adsorption' do
  it dimer(cr: :*) + methan(:*) == methyl_on_dimer
  entalpy -73.6
  activation 0
  forward_rate 1e13, 'cm3/(mol * s)'
  reverse_rate 5.3e3
end

# не до конца понятна логика возникновения данной конфигурации в терминах анализатора
reaction 'methyl desorption from top' do
  it metyl_on_bridge == bridge(ct: :*) + methan(:*)
  activation 0
  forward_rate 1.7e7 # возможно следует также учесть обратную (на самом деле она получится прямой) реакцию, хоть у неё и очень маленькая скорость
end

# TODO: необходимо определить новый вид, для возможности записи данной реакции
#reaction 'methyl desorption from bottom' do
#  it metyl_on_bridge == bridge(cr: :*) + methan(:*)
#  activation 0
#  forward_rate 5.4e6
#end

reaction 'methyl activation' do
  it metyl_on_dimer + hydrogen(:*) == methyl_on_dimer(cm: :*) + hydrogen
  activation 37.5
  forward_rate 2.8e8 * T ** 3.5, 'cm3/(mol * s)'
end

reaction 'methyl deactivation' do
  it metyl_on_dimer(cm: :*) + hydrogen(:*) == methyl_on_dimer
  activation 0
  forward_rate 4.5e13, 'cm3/(mol * s)'
end

reaction 'same methyl-dimer hydrogen migration' do
  it methyl_on_dimer(cm: :*) == methyl_on_dimer(cl: :*)
#  entalpy -10
#  activation 29.8
#  forward_rate 4.6e6
#  reverse_rate 6e4

  forward_activation 37.5
  forward_rate 2.1e12
  reverse_activation 50.5
  reverse_rate 1.2e12
end

reaction 'chain neighbour methyl-dimer hydrogen migration' do
  it methyl_on_dimer + dimer(cr: :*) == methyl_on_dimer(cm: :*) + dimer do
    pos methyl_on_dimer(:cr), dimer(:cr), face: :100, dir: :front
  end
  
#  entalpy -8.8
#  activation 16.3
#  forward_rate 1.8e9
#  reverse_rate 1.3e8

  forward_activation 16.3
  forward_rate 1.7e12
  reverse_activation 25.1
  reverse_rate 4.8e12
end

reaction 'row neighbour methyl-dimer hydrogen migration' do
  it methyl_on_dimer + dimer(cr: :*) == methyl_on_dimer(cm: :*) + dimer do
    pos methyl_on_dimer(:cr), dimer(:cr), face: :100, dir: :cross
  end

  forward_activation 27.4
  forward_rate 1.7e12
  reverse_activation 36.6
  reverse_rate 4.8e12
end

reaction 'chain neighbour dimermethyl-fixedbridge hydrogen migration' do
  it methyl_on_dimer + bridge(cr: :*) == methyl_on_dimer(cm: :*) + bridge do
    pos methyl_on_dimer(:cr), bridge(:cr), face: :100, dir: :front
  end

  activation 12.9
  forward_rate 7.4e9
  reverse_rate 1.1e11
end

# не определено дальнейшее поведение метила после отделения у него атома водорода. в настоящий момент, он будет продолжать болтаться на поверхности
# возможно следует убрать эту реакцию
reaction 'chain neighbour bridgemethyl-fixedbridge hydrogen migration' do
  it methyl_on_bridge + bridge(cr: :*) == methyl_on_bridge(cm: :*) + bridge do
    pos methyl_on_bridge(:cb), bridge(:cr), face: :100, dir: :front
  end

  activation 14.1
  forward_rate 4.5e9
  reverse_rate 2e12
end

reaction 'chain neighbour bridge-fixedbridge hydrogen migration' do
  it bridge(cr: :*) + bridge == bridge + bridge(ct: :*) do
    pos bridge(:cr), bridge(:ct), face: :100, dir: :front
  end
  
  activation 7
  forward_rate 6.6e10
  reverse_rate 1e10
end

reaction 'chain neighbour bridge-dimer hydrogen migration' do
  it dimer(cr: :*) + bridge == dimer + bridge(ct: :*) do
    pos dimer(:cr), bridge(:ct), face: :100, dir: :front
  end

  activation 23.6
  forward_rate 6.2e7
  reverse_rate 1.4e5
end

reaction 'dimer hydrogen migration' do
  it dimer(cr: :*) == dimer(cl: :*)
  activation 51
  forward_rate 2.3e13
end

reaction 'bridge-bridge dimer formation' do
  it bridge(ct: :*) + bridge(ct: :*) == dimer # определение положения атомов выводится исходя из димера (результата реакции)?
  entalpy -43
  activation 0
  forward_rate 8.9e11
  reverse_rate 2.2e6
end

reaction 'bridge-fixedbridge dimer formation' do
  it bridge(ct: :*) + bridge(cr: :*) == bridge_and_dimer
  activation 0.7
  forward_rate 7.5e11
  reverse_rate 1.2e11
end

reaction 'methyl to high bridge' do
  it methyl_on_dimer(cm: :*) == bridge(ct: :*) + high_bridge do
    pos bridge(:ct), high_bridge(:ct), face: :100, dir: :front
  end

  # TODO: проверить соответствие значений направленности
  forward_activation 15.3
  forward_rate 9.8e12
  reverse_activation 2.9
  reverse_rate 2.7e11
end

reaction 'high bridge to bridge on bridges' do
  it high_bridge + bridge(ct: :*) == bridge_on_bridges(cr: :*) do
    pos high_bridge(:ct), bridge(:ct), face: :100, dir: :front
    same high_bridge(:ct), bridge_on_bridges(:cr)
  end

  # TODO: аналогично проверить значения
  forward_activation 36.3
  forward_rate 6.1e13
  reverse_activation 12.3
  reverse_rate 1.1e12
end

#reaction 'high bridge to bridge and dimer'
#reaction 'high bridge to two bridges on three'
#
