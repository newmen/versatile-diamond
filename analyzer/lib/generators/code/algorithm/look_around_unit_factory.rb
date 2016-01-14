module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction look around algorithm units
        class LookAroundUnitsFactory < LateralChunksUnitsFactory

          # Gets the lateral chunk creator unit
          # @param [LateralReaction] lateral_reaction instance of which will allocated
          # @param [Array] sidepiece_species required for creation lateral reaction
          # @return [Units::ReactionLookAroundCreatorUnit] the unit for defines lateral
          #   chunk creation code block
          def creator(*args)
            Units::ReactionLookAroundCreatorUnit.new(*default_args, *args)
          end
        end

      end
    end
  end
end
