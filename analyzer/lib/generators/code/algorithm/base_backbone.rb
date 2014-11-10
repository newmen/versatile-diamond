module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides base logic for backbone instance
        # @abstract
        class BaseBackbone
          extend Forwardable

          # Initializes backbone by grouped nodes graph
          # @param [Hash] group
          def initialize(grouped_nodes_graph)
            @grouped_nodes_graph = grouped_nodes_graph
          end

        private

          def_delegator :@grouped_nodes_graph, :final_graph

          # Collects all nodes from final graph
          # @return [Array] the sorted array of nodes lists
          def collect_nodes(graph)
            lists = graph.each_with_object([]) do |(nodes, rels), acc|
              acc << nodes
              rels.each { |ns, _| acc << ns }
            end
            lists.uniq.sort_by(&:size)
          end
        end

      end
    end
  end
end
