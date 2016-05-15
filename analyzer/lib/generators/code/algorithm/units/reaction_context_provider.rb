module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of reaction find algoritnm builder
        class ReactionContextProvider < BaseContextProvider
          # @param [Array] nodes
          # @return [Boolean]
          def relations_from?(nodes)
            backbone_graph.any? do |key, rels|
              !rels.empty? && nodes == key
            end
          end

        private

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
