module VersatileDiamond
  module Generators
    module Code

      # Wraps swapped symmetric specie
      # @abstract
      class SwappedSpecie < EmptySpecie

        # Also remembers indexes of swapped atoms
        # @param [EngineCode] generator see at #super same argument
        # @param [BaseSpecie] specie see at #super same argument
        # @param [Integer] from_index the atom index which will be swapped
        # @param [Integer] to_index the atom index to which will be swapped
        # @option [Boolean] :registrate see at #super same argument
        # @override
        def initialize(generator, specie, from_index, to_index, registrate: true)
          super(generator, specie, registrate: registrate)
          @from_index, @to_index = from_index, to_index
        end

      private

        # Gets the additional template parameters of base cpp class
        # @return [Array] the array of additional template arguments
        def additional_template_args
          [@from_index, @to_index]
        end
      end

    end
  end
end
