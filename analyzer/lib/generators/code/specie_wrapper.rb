module VersatileDiamond
  module Generators
    module Code

      # Provides methods that allows to wrap some another empty or wrapped specie
      class SpecieWrapper

        def initialize(empty_specie, index = nil)
          @specie = empty_specie
          @index = index
        end

      private

        # Gets the base class of cpp class of symmetric specie
        # @return [String] the name of base class
        def base_class_name
          "#{wrapper_class}<Empty<#{enum_name}>, #{@from_index}, #{@to_index}>"
        end

        # Defines wrapper class name
        # @return [String] the engine wrapper class name
        def wrapper_class
          'AtomsSwapWrapper'
        end
      end

    end
  end
end
