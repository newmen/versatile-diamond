module VersatileDiamond
  module Generators
    module Code

      # Creates atom swapped symmetric specie
      class AtomsSwappedSpecie < SymmetricSpecie
      private

        # Defines wrapper class name
        # @return [String] the engine wrapper class name
        def wrapper_class
          'AtomsSwapWrapper'
        end
      end

    end
  end
end
