module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for create nodes for chunks of lateral reaction and group them
        # by parameters of relations
        class ChunksGroupedNodes < BaseGroupedNodes

          # Initializes nodes grouper for chunks of all lateral reactions which are
          # children of passed typical reaction
          #
          # @param [EngineCode] generator the major code generator
          # @param [TypicalReaction] reaction from which the grouped graph of chunks of
          #   children lateral reactions will be gotten
          # @param [Array] chunks of children lateral reactions of passed typical
          #   reaction
          def initialize(generator, reaction, chunks)
            super(ReactionNodesFactory.new(generator))
            @reaction = reaction
            @chunks = chunks
          end

        end

      end
    end
  end
end
