class Equation < ComplexComponent
  def initialize(str)
    sides = Matcher.equation(str)
    syntax_error('.invalid') unless sides
    @source, @products = sides.map { |specs| specs.map(&method(:detect_spec)) }
    syntax_error('.wrong_balance') if external_bonds_sum(@source) != external_bonds_sum(@products)
  end

private

  def detect_spec(spec_str)
    if Matcher.active_bond(spec_str)
      ActiveBond.instance
    elsif (atom_name = Matcher.atom(spec_str))
      AtomicSpec.new(spec_str)
    else
      SpecificSpec.new(spec_str)
    end
  end

  def external_bonds_sum(specs)
    specs.map(&:external_bonds).inject(:+)
  end
end
