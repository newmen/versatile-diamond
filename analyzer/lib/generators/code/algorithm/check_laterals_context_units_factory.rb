module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for check laterals find algorithm
        class CheckLateralsContextUnitsFactory < LateralChunksContextUnitsFactory
          # @param [LateralChunks] lateral_chunks
          # @return [Units::CheckLateralsCreationUnit]
          def creator(lateral_chunks)
            Units::CheckLateralsCreationUnit.new(dict, context, lateral_chunks)
          end
        end

      end
    end
  end
end
