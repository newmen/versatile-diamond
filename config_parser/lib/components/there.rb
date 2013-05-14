class There < Component
  include EquationProperties

  def initialize(equation, concreted_wheres)
    @equation, @concreted_wheres = equation, concreted_wheres
  end

  def equation_instance
    @equation
  end
end
