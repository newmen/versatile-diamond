require_relative '../../../keyname_graph_converter.rb'

module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm
        module Support

          # Provides usefull methods for working with noded graphs
          module NodesConverter
            include VersatileDiamond::Support::KeynameGraphConverter
            include Algorithm::NodesCollector

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
              collect_nodes(nodes_graph).flatten.uniq.map(&method(:typed_node))
            end

            # Translates the passed list or graph to another list where instead nodes
            # the atoms uses
            #
            # @param [Array | Hash] nodes_list which will be translated
            # @return [Array] translated atomic list of relations
            # @override
            alias_method :super_translate_to_keyname_list, :translate_to_keyname_list
            def translate_to_keyname_list(nodes_list)
              spec_name_proc = -> n { n.spec.name }
              all_keys_proc = -> scope { scope.reduce(:+) }
              super_translate_to_keyname_list(nodes_list, spec_name_proc, all_keys_proc)
            end

            # Translates the passed graph to another graph where instead vertices the
            # atoms uses as keynames
            #
            # @param [Array] nodes_list which will be translated
            # @param [Hash] graph which will be translated
            # @return [Hash] translated atomic graph
            # @override
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
