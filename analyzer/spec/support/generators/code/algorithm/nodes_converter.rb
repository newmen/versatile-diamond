module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          # Provides usefull methods for working with noded graphs
          module NodesConverter

            # Grubs atoms from nodes
            # @param [Array] nodes from which the atoms will be gotten
            # @return [Array] the array of atoms
            def grep_keynames(nodes)
              nodes.map(&:keyname)
            end

            # Collects the list of unique nodes which used in passed graph
            # @param [Hash] nodes_graph from which the list will be collected
            # @return [Array] the list of converted nodes
            def typed_nodes_list(nodes_graph)
              nodes_graph.keys.flatten.map(&method(:typed_node)).uniq
            end

            # Translates the passed list or graph to another list where instead nodes
            # the atoms uses
            #
            # @param [Array | Hash] nodes_list which will be translated
            # @return [Array] translated atomic list of relations
            def translate_to_keyname_list(nodes_list)
              nodes_list.map do |nodes, rels|
                new_rels = rels.map { |ns, r| [grep_keynames(ns), r] }
                [grep_keynames(nodes), new_rels]
              end
            end

            # Translates the passed graph to another graph where instead nodes the
            # atoms uses as vertices
            #
            # @param [Hash] nodes_graph which will be translated
            # @return [Hash] translated atomic graph
            def translate_to_keyname_graph(nodes_graph)
              Hash[translate_to_keyname_list(nodes_graph)]
            end

          private

            # Provides simple array with two element instead of the node
            # @param [BaseNode] node which will be converted
            # @return [Array] the simple checkable array with two values
            def typed_node(node)
              [node.uniq_specie.class, node.keyname]
            end
          end

        end
      end
    end
  end
end
