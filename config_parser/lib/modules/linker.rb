module Linker
  # @return [spec_name_sym, atom_keyname_sym]
  def match_used_atom(used_atom_str)
    match = Matcher.used_atom(used_atom_str)
    match && match.all? ? match.map(&:to_sym) : syntax_error('linker.undefined_used_atom', name: used_atom_str)
  end

  def link(var_symbol, first_atom, second_atom, link_instance)
    links = instance_variable_get(var_symbol) || instance_variable_set(var_symbol, {})
    links[first_atom] ||= []
    links[first_atom] << [second_atom, link_instance]
    links[second_atom] ||= []
    links[second_atom] << [first_atom, link_instance]
  end
end
