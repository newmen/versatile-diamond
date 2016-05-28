module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Provides method for extending graph to anchored nodes
        module BackboneExtender
        private

          # Checks that passed graph do not contains unanchored nodes on other side
          # @param [Hash] graph which will be checked
          # @return [Boolean] closed by anchors or not
          def totaly_closed?(graph)
            grouped_side_nodes = other_side_nodes(graph)
            flatten_site_nodes = grouped_side_nodes.reduce(:+)
            grouped_side_nodes.all? do |nodes|
              nodes.any? do |node|
                node.anchor? || flatten_site_nodes.any? do |n|
                  n.uniq_specie == node.uniq_specie && n.anchor?
                end
              end
            end
          end

          # @param [Hash] graph which extended instance will be gotten
          # @return [Hash] the extended graph with anchor nodes on sides
          def cut_and_extend_to_anchors(graph)
            extend_all_branches(extend_own_branches(cut_own_branches(graph)), graph)
          end

          # @param [Hash] graph which will be cutten
          # @return [Hash] the cutten graph
          def cut_own_branches(graph)
            graph.select { |key, _| own_key?(key) }
          end

          # @param [Hash] graph which extended instance will be gotten
          # @return [Hash] the extended graph with anchor nodes on sides
          def extend_own_branches(graph)
            other_side_nodes(graph).reduce(graph) do |acc, nodes|
              nodes.any?(&:anchor?) ? acc : extend_graph(acc, nodes)
            end
          end

          # @param [Hash] extending_graph which extended instance will be gotten
          # @param [Hash] grouped_final_graph by which another nodes will be selected
          # @return [Hash] the extended graph with anchor nodes on sides
          def extend_all_branches(extending_graph, grouped_final_graph)
            result = extending_graph
            final_keys = grouped_final_graph.keys
            final_nodes = nodes_set(grouped_final_graph)
            loop do
              next_nodes = nil
              reached_nodes = nodes_set(result)
              if reached_nodes.size < final_nodes.size
                next_nodes = final_keys.find { |k| k.to_set == reached_nodes }
                result = extend_graph(result, next_nodes) if next_nodes
              end
              return result unless next_nodes
            end
          end

          # @param [Array] graphs
          # @return [Hash]
          def best_graph(graphs)
            gwasz = graphs.map { |g| [g, nodes_set(g).select(&:anchor?).size] }
            max_n = gwasz.map(&:last).max
            maximal_anchored = gwasz.select { |_, n| n == max_n }.map(&:first)
            maximal_anchored.sort_by { |g| g.values.reduce(:+).size }.first
          end

          # Extends passed graph from passed nodes to nodes with anchor atom
          # @param [Hash] graph which extended instance will be gotten
          # @param [Array] nodes from which graph will be extended
          # @return [Hash] the extended graph or nil if extending was not successful
          def extend_graph(graph, nodes)
            next_rels = next_ways(graph, nodes)
            return graph if next_rels.empty? # stop recursive find for this graph

            vs = extending_ways(graph, next_rels)
            anchored_vs = vs.select { |_, ns| ns.any?(&:anchor?) }
            complete_vs = anchored_vs.select { |g, _| totaly_closed?(g) }

            extended_graphs =
              if complete_vs.empty?
                resolving_vs = anchored_vs.empty? ? vs : anchored_vs
                resolving_vs.map { |nwg| extend_graph(*nwg) }
              else
                complete_vs.map(&:first)
              end

            best_graph(extended_graphs.uniq) || graph
          end

          # Tries to extend passed graph in directions of next relations
          # @param [Hash] graph the initial value for next extended graphs
          # @param [Array] next_rels in which the expanding will be occured
          # @return [Array] the list of extending results for each direaction
          def extending_ways(graph, next_rels)
            next_rels.group_by(&:last).map do |rp, group|
              from_nodes, next_nodes = group.map(&:first).transpose.map(&:uniq)

              ext_graph = graph.dup
              ext_graph[from_nodes] ||= []
              ext_graph[from_nodes] += [[next_nodes, rp]]

              [ext_graph, next_nodes]
            end
          end

          # Gets the next ways by which the target graph could be extended
          # @param [Hash] graph for which the extending ways will be gotten
          # @param [Array] nodes from which ways will be found
          # @return [Array] the list of triples where first item of triple is
          #   from_node, the second item is next_node and last item is relation
          #   parameters hash
          def next_ways(graph, nodes)
            prev_nodes = nodes_set(graph)
            nodes.flat_map do |node|
              all_rels = big_ungrouped_graph[node]
              next_rels = all_rels.select do |n, r|
                !prev_nodes.include?(n) &&
                  r.exist? && n.uniq_specie == node.uniq_specie
              end
              next_rels.map { |n, r| [[node, n], r.params] }
            end
          end

          # Collects the set of all used nodes from passed graph
          # @param [Hash] graph from which the nodes will be collected
          # @return [Set] the set of all used nodes
          def nodes_set(graph)
            collect_nodes(graph).reduce(:+).to_set
          end

          # Gets the nodes list which uses in relations of passed graph
          # @param [Hash] graph from which relations the nodes will be gotten
          # @return [Array] the list of other side nodes
          def other_side_nodes(graph)
            bg = big_ungrouped_graph
            graph.flat_map do |nodes, rels|
              rels.map do |nbrs, _|
                nodes.flat_map do |node|
                  bg[node].select { |n, r| r.exist? && nbrs.include?(n) }.map(&:first)
                end
              end
            end
          end
        end

      end
    end
  end
end
