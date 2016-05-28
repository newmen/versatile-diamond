module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides method for collecting nodes from some graph
        module NodesCollector
        private

          # Collects all nodes from final graph
          # @return [Array] the sorted array of nodes lists
          def collect_nodes(graph)
            lists = graph.flat_map { |nodes, rels| [nodes] + rels.map(&:first) }
            lists.uniq.sort_by(&:size)
          end
        end

      end
    end
  end
end
