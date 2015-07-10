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
          # @param [LateralChunks] lateral_chunks for which the grouped graph will be
          #   builded
          def initialize(generator, lateral_chunks)
            super(ReactionNodesFactory.new(generator))
            @lateral_chunks = lateral_chunks
          end

        end

      end
    end
  end
end
