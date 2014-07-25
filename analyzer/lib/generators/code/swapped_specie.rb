module VersatileDiamond
  module Generators
    module Code

      # Wraps swapped symmetric specie
      # @abstract
      class SwappedSpecie < EmptySpecieWrapper

        # Also remembers indexes of swapped atoms
        # @param [EmptySpeciesCounter] counter see at #super same argument
        # @param [EmptySpecie | SpecieWrapper] empty_specie see at #super same argument
        # @param [Integer] from_index the atom index which will be swapped
        # @param [Integer] to_index the atom index to which will be swapped
        # @override
        def initialize(counter, empty_specie, from_index, to_index)
          super(counter, empty_specie)
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
