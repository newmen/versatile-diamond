module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksFindBuilder < FindAlgorithmBuilder

          # Inits builder by main engine code generator and lateral chunks object
          # @param [LateralChunksBackbone] backbone of algorithm
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(backbone, lateral_chunks)
            super(backbone)
            @lateral_chunks = lateral_chunks
          end

        private

          # @param [Units::ReactionContextProvider] context
          # @return [LateralContextUnitsFactory]
          def make_context_factory(context)
            LateralContextUnitsFactory.new(dict, pure_factory, context)
          end

          # @param [Array] ordered_graph
          # @return [Units::ReactionContextProvider]
          def make_context_provider(ordered_graph)
            Units::ReactionContextProvider.new(dict, nodes_graph, ordered_graph)
          end

          # @oaram [LateralContextUnitsFactory] factory
          # @return [Units::LateralChunkCreationUnit]
          def make_creator_unit(factory)
            factory.creator(@lateral_chunks)
          end
        end

      end
    end
  end
end
