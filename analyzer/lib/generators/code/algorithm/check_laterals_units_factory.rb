module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction check laterals algorithm units
        class CheckLateralsUnitsFactory < LateralChunksUnitsFactory

          # Gets the lateral chunk creator unit
          # @param [LateralReaction] lateral_reaction which will be created
          # @param [Instances::UniqReactant] target specie from which the find
          #   algorithm doing
          # @param [Array] sidepiece_species which locates near target specie
          # @return [Units::ReactionCheckLateralsCreatorUnit] the unit for defines
          #   lateral chunk creation code block
          def creator(*args)
            creator_args = [lateral_chunks] + args
            Units::ReactionCheckLateralsCreatorUnit.new(*default_args, *creator_args)
          end
        end

      end
    end
  end
end
