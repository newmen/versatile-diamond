module VersatileDiamond
  module Generators
    module Code

      # Creates parents swapped symmetric specie
      class ParentsSwappedSpecie < SymmetricSpecie
      private

        # Defines wrapper class name
        # @return [String] the engine wrapper class name
        def wrapper_class
          'ParentsSwapWrapper'
        end
      end

    end
  end
end
