module VersatileDiamond
  module Generators
    module Code

      # Creates atoms swapped symmetric specie
      class AtomsSwappedSpecie < SwappedSpecie
      private

        # Defines wrapper class name
        # @return [String] the engine wrapper class name
        def wrapper_class_name
          'AtomsSwapWrapper'
        end
      end

    end
  end
end
