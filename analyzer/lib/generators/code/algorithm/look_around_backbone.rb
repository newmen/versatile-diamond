module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the look around algorithm will be built
        class LookAroundBackbone < LateralChunksBackbone
          def_delegators :grouped_nodes_graph, :action_nodes

        private

          # Makes clean graph with relations only from target nodes
          # @return [Hash] the grouped graph with relations only from target nodes
          def make_final_graph
            grouped_graph.select { |nodes, _| target_nodes?(nodes) }
          end

          # Checks that passed nodes contains specs which belongs to target specs
          # @param [Array] nodes which will be checked
          # @return [Boolean] are all nodes contain target spec
          def target_nodes?(nodes)
            nodes.all? { |node| lateral_chunks.target_spec?(node.spec.spec) }
          end

          # @param [Array] nodes
          # @return [Array]
          def keys_related_to(nodes)
            reactions = nodes.map(&method(:reaction_with))
            final_graph.each_with_object([]) do |(key, rels), acc|
              nbrs = rels.flat_map(&:first)
              acc << key if nbrs.any? { |n| reactions.include?(reaction_with(n)) }
            end
          end

          # Makes small directed graph for check sidepiece species
          # @param [Array] nodes for which the graph will returned
          # @return [Array] the ordered list that contains the relations from final
          #   graph
          def raw_directed_graph_from(nodes)
            other_side = final_graph[nodes]
            result = [[nodes, other_side]]
            other_side.each_with_object(result) do |(nbrs, _), acc|
              keys_related_to(nbrs).each do |key|
                acc << [key, final_graph[key]] unless key == nodes
              end
            end
          end

          # @param [Array] nodes
          # @return [LateralReaction] single lateral reaction
          def reaction_with(node)
            lateral_chunks.select_reaction(node.spec_atom)
          end
        end

      end
    end
  end
end
