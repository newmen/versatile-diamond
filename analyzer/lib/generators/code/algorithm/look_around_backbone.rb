module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Cleans the chunks grouped nodes graph from not significant relations and
        # gets the ordered graph by which the look around algorithm will be built
        class LookAroundBackbone < LateralChunksBackbone
        private

          def_delegator :lateral_nodes_factory, :target_node

          # @return [Symbol] name of predicate function
          def target_predicate_name
            :target_spec?
          end

          # Gets list of spec-atom pairs from which the action nodes will be mapped
          # @return [Array] the list of target spec-atom pairs
          def action_keys
            lateral_chunks.targets
          end

          # @param [Array] key_with_rels
          # @return [Array]
          def key_group_by_slice(key_with_rels)
            key, rels = key_with_rels
            [key.map(&:original).to_set, reactions_set_from(rels)]
          end

          # @param [Array] ordered_graph
          # @return [Array]
          def group_by_reactions(ordered_graph)
            ordered_graph.groups { |_, rels| reactions_set_from(rels) }
          end

          # @param [Array] rels
          # @return [Set]
          def reactions_set_from(rels)
            rels.flat_map(&:first).map(&:lateral_reaction).to_set
          end
        end

      end
    end
  end
end
