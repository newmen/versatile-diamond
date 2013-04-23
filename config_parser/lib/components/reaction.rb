class Reaction < ComplexComponent
  include EquationProperties

  def initialize(name)
    @name = name
  end

  def equation(str)
    @equation = Equation.add(str, @name)
    nested(@equation)
  end

private

  def equation_instance
    @equation || syntax_error('.need_define_equation')
  end
end
