module VersatileDiamond

  class Reaction < ComplexComponent
    include EquationProperties

    def initialize(name)
      @name = name
    end

    def aliases(**refs)
      @aliases = refs # checks in equation
    end

    def equation(str)
      @equation = Equation.add(str, @name, @aliases)
      nested(@equation)
    end

  private

    def equation_instance
      @equation || syntax_error('.need_define_equation')
    end
  end

end
