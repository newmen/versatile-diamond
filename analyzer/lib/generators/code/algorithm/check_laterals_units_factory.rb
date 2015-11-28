module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction check laterals algorithm units
        class CheckLateralsUnitsFactory < LateralChunksUnitsFactory

          # Gets the lateral chunk creator unit
          # @param [LateralReaction] lateral_reaction which will be created
          # @param [UniqSpecie] target specie from which the find algorithm doing
          # @param [Array] sidepiece_species which locates near target specie
          # @return [ReactionCheckLateralsCreatorUnit] the unit for defines lateral
          #   chunk creation code block
          def creator(*args)
            ReactionCheckLateralsCreatorUnit.new(namer, lateral_chunks, *args)
          end

          # Gets the other side species checker unit
          # @param [Array] otherside_sidepieces_with_atoms the list of absolutely
          #   unique otherside species with them atoms
          # @param [Array] prev_sidepieces the list of sidepieces which was used at
          #   previos steps
          # @return [CheckLateralsOthersideSpeciesCheckerUnit] the unit which will
          #   check sidepiece species
          def checker(*args)
            CheckLateralsOthersideSpeciesCheckerUnit.new(namer, *args)
          end
        end

      end
    end
  end
end
