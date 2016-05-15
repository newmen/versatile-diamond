module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the look around algorithm will be built
        class LookAroundBackbone < LateralChunksBackbone
          include ListsComparer

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

          # @return [Array]
          def grouped_keys
            final_graph.keys.groups { |key| reactions_set_from(final_graph[key]) }
          end

          # @param [Array] nodes
          # @return
          def grouped_slices(nodes)
            slices_with(nodes).groups { |_, rels| reactions_set_from(rels) }
          end

          # @param [Array] rels
          # @return [Set]
          def reactions_set_from(rels)
            rels.flat_map(&:first).map(&method(:reaction_with)).to_set
          end
        end

      end
    end
  end
end
