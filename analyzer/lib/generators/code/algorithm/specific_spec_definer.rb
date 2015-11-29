module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for units which uses simple specific species
        module SpecificSpecDefiner
        private

          # Gets the engine framework class for reactant specie
          # @return [String] the engine framework class for reactant specie
          def specie_type
            'SpecificSpec'
          end
        end

      end
    end
  end
end
