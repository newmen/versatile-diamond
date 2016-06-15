module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm
        module Support

          # Provides usefull methods for working with noded graphs
          module NodesConverter
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
            def translate_to_keyname_list(nodes_list)
              all_nodes = nodes_list.flat_map do |key, rels|
                key + rels.flat_map(&:first)
              end

              nds_to_kns = {}
              nodes_with_keynames = all_nodes.map { |n| [n, n.keyname] }.uniq
              groups = nodes_with_keynames.groups(&:last)
              groups.select(&:one?).each do |group|
                node, keyname = group.first
                nds_to_kns[node] = keyname
              end

              groups.reject(&:one?).each do |group|
                sub_groups = group.groups { |n, _| n.spec.name }
                sub_groups.select(&:one?).each do |g|
                  node, keyname = g.first
                  nds_to_kns[node] = :"#{node.spec.name}__#{keyname}"
                end
                sub_groups.reject(&:one?).each do |g|
                  g.each_with_index do |(node, keyname), i|
                    nds_to_kns[node] = :"#{node.spec.name}__#{i}__#{keyname}"
                  end
                end
              end

              kn_proc = nds_to_kns.public_method(:[])
              nodes_list.map do |nodes, rels|
                [nodes.map(&kn_proc), rels.map { |ns, r| [ns.map(&kn_proc), r] }]
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
