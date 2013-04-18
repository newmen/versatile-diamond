class Run < Component
  def total_time(value, dimension = nil)
    @total_time = Dimensions.convert_time(value, dimension)
  end

  def atom_termination(value)
    @atom_termination =
      if value == '*'
        value
      elsif (atom = Atom[value]) && atom.valence == 1
        atom
      else
        syntax_error('.invalid_atom_termination', value: value)
      end
  end
end
