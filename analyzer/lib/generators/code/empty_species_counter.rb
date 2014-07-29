module VersatileDiamond
  module Generators
    module Code

      # Counts empty specie code generators for correct get an index of symmetric
      # specie
      class EmptySpeciesCounter

        # Initialize the internal cache map for counts empty species
        def initialize
          @counter = {}
        end

        # Increments internal index of symmetric specie of wrapped specie
        # @param [EmptySpecie] empty_specie the specie for which next index of
        #   symmetric specie will be gotten
        # @return [Integer] the index of new created symmetric specie
        def next_index(empty_specie)
          @counter[empty_specie.counter_key] ||= 0
          @counter[empty_specie.counter_key] += 1
        end

        # Checks that for some empty specie has many symmetric instances
        # @param [EmptySpecie] empty_specie the specie by which the number will be
        #   gotten
        # @return [Boolean] many or one
        def many_symmetrics?(empty_specie)
          @counter[empty_specie.counter_key] > 1
        end
      end

    end
  end
end
