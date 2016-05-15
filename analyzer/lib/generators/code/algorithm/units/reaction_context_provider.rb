module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm::Units

        # The context for units of reaction find algoritnm builder
        class ReactionContextProvider < BaseContextProvider
          # @param [Array] nodes
          # @return [Boolean]
          def relations_from?(nodes)
            backbone_graph.any? { |key, rels| !rels.empty? && nodes == key }
          end

        private

          # @param [Array] nodes
          # @return [Array]
          def same_related_nodes(nodes)
            nwbrs = nodes.map { |n| [n, both_directions_bone_relations_of_one(n)] }
            groups = nwbrs.groups do |_, rels|
              rels.map { |n, r| [n.properties, r] }.to_set
            end
            groups.select(&:one?).flat_map { |group| group.map(&:first) }
          end

          # @param [Nodes::BaseNode] node
          # @return [Array] nodes
          # @return [Boolean]
          def bone_with?(node, nodes)
            specie = node.uniq_specie
            nodes.any? { |n| bone_relation?(node, n) || n.uniq_specie == specie } &&
              !both_units_related?(node, nodes)
          end
        end

      end
    end
  end
end
