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
            uniq_lists = lists.uniq.reject do |ns|
              (!graph[ns] || graph[ns].empty?) &&
                ns.permutation.any? { |nk| graph[nk] && !graph[nk].empty? }
            end
            uniq_lists.sort
          end
        end

      end
    end
  end
end
