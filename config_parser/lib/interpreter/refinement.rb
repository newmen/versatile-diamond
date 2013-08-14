module VersatileDiamond
  module Interpreter

    # TODO: rspec
    class Refinement < Component
      # extend Forwardable
      include EquationProperties

      def initialize(reaction, names_and_specs)
        @reaction = reaction
        @names_and_specs = names_and_specs
      end

      # def_delegators :equation_instance, :position, :incoherent #, :unfixed

      # def equation_instance
      #   @equation
      # end
    end

  end
end
