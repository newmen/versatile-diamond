module VersatileDiamond

  class Refinement < Component
    extend Forwardable
    include EquationProperties

    def initialize(equation)
      @equation = equation
    end

    def_delegators :equation_instance, :position, :incoherent #, :unfixed

    def equation_instance
      @equation
    end
  end

end
