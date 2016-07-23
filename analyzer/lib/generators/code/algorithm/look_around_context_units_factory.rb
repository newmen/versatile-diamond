module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for look around find algorithm
        class LookAroundContextUnitsFactory < LateralChunksContextUnitsFactory
          # @return [Units::LookAroundCreationUnit]
          def creator
            Units::LookAroundCreationUnit.new(dict, context)
          end
        end

      end
    end
  end
end
