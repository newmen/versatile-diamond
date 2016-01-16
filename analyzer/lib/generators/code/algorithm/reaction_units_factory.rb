module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates reaction find algorithm units
        class ReactionUnitsFactory < BaseReactionUnitsFactory

          # Initializes reaction find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction for which the algorithm is building
          def initialize(generator, reaction)
            super(generator)
            @reaction = reaction
          end

          # Gets the reaction creator unit
          # @return [Units::ReactionCreatorUnit] the unit for defines reaction creation
          #   code block
          def creator
            Units::ReactionCreatorUnit.new(*default_args)
          end

        private

          # Gets the checking context which will be passed to each creating unit
          # @return [TypicalReaction] the context which targeted to inner specie
          def context
            @reaction
          end
        end

      end
    end
  end
end
