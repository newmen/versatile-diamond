module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides logic for units which uses lateral species
        module LateralSpecDefiner
        private

          # Gets the engine framework class for reactant specie
          # @return [String] the engine framework class for reactant specie
          def specie_type
            'LateralSpec'
          end
        end

      end
    end
  end
end
