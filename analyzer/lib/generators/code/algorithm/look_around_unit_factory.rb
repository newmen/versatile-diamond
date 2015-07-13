module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction look around algorithm units
        class LookAroundUnitsFactory < LateralChunksUnitsFactory

          # Gets the lateral chunk creator unit
          # @param [LateralReaction] lateral_reaction instance of which will allocated
          # @param [Array] sidepiece_species required for creation lateral reaction
          # @return [SingleLateralReactionCreatorUnit] the unit for defines lateral
          #   chunk creation code block
          def creator(lateral_reaction, sidepiece_species)
            args = [namer, lateral_reaction, sidepiece_species]
            ReactionLookAroundCreatorUnit.new(*args)
          end
        end

      end
    end
  end
end
