module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          # Provides usefull methods for working with noded graphs
          module NodesConverter

            def typed_node(node)
              [node.uniq_specie.class, node.atom]
            end

            def typed_nodes_list(nodes_graph)
              nodes_graph.keys.flatten.map(&method(:typed_node)).uniq
            end

            def translate_to_atomic_graph(nodes_graph)
              nodes_graph.each_with_object({}) do |(nodes, rels), acc|
                acc[nodes.map(&:atom)] = rels.map { |ns, r| [ns.map(&:atom), r] }
              end
            end
          end

        end
      end
    end
  end
end
