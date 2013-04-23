module Linker
  def link(var_symbol, first_atom, second_atom, link_instance, define_var: false)
    hash = instance_variable_get(var_symbol) || (define_var && instance_variable_set(var_symbol, {}))
    hash[first_atom] ||= []
    hash[first_atom] << [second_atom, link_instance]
    hash[second_atom] ||= []
    hash[second_atom] << [first_atom, link_instance]
  end
end
