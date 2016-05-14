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
        end

      end
    end
  end
end
