module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides logic for units which uses parent species
        module ParentSpecDefiner
        private

          # Gets the default engine framework class for parent specie
          # @return [String] the engine framework class for parent specie
          def specie_type
            'ParentSpec'
          end
        end

      end
    end
  end
end
