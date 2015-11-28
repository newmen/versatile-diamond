module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction look around algorithm units
        class LookAroundUnitsFactory < LateralChunksUnitsFactory

          # Gets the lateral chunk creator unit
          # @param [LateralReaction] lateral_reaction instance of which will allocated
          # @param [Array] sidepiece_species required for creation lateral reaction
          # @return [ReactionLookAroundCreatorUnit] the unit for defines lateral chunk
          #   creation code block
          def creator(*args)
            ReactionLookAroundCreatorUnit.new(namer, *args)
          end

          # Gets the other side species checker unit
          # @param [Array] otherside_sidepieces_with_atoms the list of absolutely
          #   unique otherside species with them atoms
          # @param [Array] prev_sidepieces the list of sidepieces which was used at
          #   previos steps
          # @return [LookAroundOthersideSpeciesCheckerUnit] the unit which will check
          #   sidepiece species
          def checker(*args)
            LookAroundOthersideSpeciesCheckerUnit.new(namer, *args)
          end
        end

      end
    end
  end
end
