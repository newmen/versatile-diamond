require 'singleton'

class Run < Component
  include Singleton

  def total_time(value, dimension = nil)
    @total_time = Dimensions.convert_time(value, dimension)
  end

  def termination(value)
    @termination =
      if value == '*'
        value
      elsif (atom = Atom[value]) && atom.valence == 1
        atom
      else
        syntax_error('.invalid_termination', value: value)
      end
  end

  def is_termination?(atom)
    @termination.name == atom.name
  end
end
