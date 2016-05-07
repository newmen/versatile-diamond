module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for specie find algorithm
        class ReactionContextUnitsFactory < BaseContextUnitsFactory
          # @param [Array] nodes for which the unit will be maked
          # @return [Units::ContextReactionUnit]
          def unit(nodes)
            Units::ContextReactionUnit.new(dict, context, pure_unit(nodes))
          end

          # @param [TypicalReaction] reaction
          # @return [Units::ReactionCreationUnit]
          def creator(reaction)
            Units::ReactionCreationUnit.new(dict, context, reaction)
          end
        end

      end
    end
  end
end
