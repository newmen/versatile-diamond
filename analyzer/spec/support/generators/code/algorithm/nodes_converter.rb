module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          # Provides usefull methods for working with noded graphs
          module NodesConverter

            # Provides simple array with two element instead of the node
            # @param [Node] node which will be converted
            # @return [Array] the simple checkable array with two values
            def typed_node(node)
              [node.uniq_specie.class, node.atom]
            end

            # Collects the list of unique nodes which used in passed graph
            # @param [Hash] node_graph from which the list will be collected
            # @return [Array] the list of converted nodes
            def typed_nodes_list(nodes_graph)
              nodes_graph.keys.flatten.map(&method(:typed_node)).uniq
            end

            # Translates the passed graph to another graph where instead nodes the
            # atoms uses as vertices
            #
            # @param [Hash] node_graph which will be translated
            # @return [Hash] translated atomic graph
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
