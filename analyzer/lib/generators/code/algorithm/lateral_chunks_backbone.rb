module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations
        # @abstract
        class LateralChunksBackbone

          # Initializes backbone by lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object for which the graph
          #   will be builded
          def initialize(generator, lateral_chunks)
            @lateral_chunks = lateral_chunks
            @grouped_nodes_graph =
              LateralChunksGroupedNodes.new(generator, lateral_chunks)

            @_final_graph = nil
          end

          # Gets entry nodes for generating algorithm
          # @return [Array] the array of entry nodes
          def entry_nodes
            final_graph.keys.sort_by(&:size)
          end

          # Cleans grouped graph from unsignificant relations
          # @return [Hash] the grouped graph with relations only from target nodes
          # TODO: must be private!
          def final_graph
            @_final_graph ||= make_final_graph
          end

          # Makes small directed graph for check sidepiece species
          # @param [Array] nodes for which the graph will returned
          # @return [Array] the ordered list that contains the relations from final
          #   graph
          def ordered_graph_from(nodes)
            [
              [nodes, final_graph[nodes]]
            ]
          end

        private

          attr_reader :lateral_chunks, :grouped_nodes_graph

          # Gets grouped graph
          # @return [LateralChunksGroupedNodes]
          def grouped_graph
            grouped_nodes_graph.final_graph
          end
        end

      end
    end
  end
end
