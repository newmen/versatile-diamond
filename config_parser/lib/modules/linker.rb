module VersatileDiamond

  module Linker
    def link(var_symbol, first_atom, second_atom, link_instance)
      links = instance_variable_get(var_symbol) || instance_variable_set(var_symbol, {})
      links[first_atom] ||= []
      links[first_atom] << [second_atom, link_instance]
      links[second_atom] ||= []
      links[second_atom] << [first_atom, link_instance]
    end
  end

end
