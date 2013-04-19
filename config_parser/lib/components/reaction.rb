class Reaction < ComplexComponent
  class << self
    def add(reaction_name)
      @reactions ||= []
      reaction = new(reaction_name)
      @reactions << reaction
      reaction
    end
  end

  def initialize(name)
    @name = name
  end

  def equation(str)
    @equation = Equation.new(str)
    nested(@equation)
  end
end
