module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of reaction find algoritnm builder
        class ReactionContextProvider < BaseContextProvider
          # @param [Array] species
          # @return [Array]
          def related_nodes_of(species)
            checking_nodes = species_nodes(species)
            cutten_backbone = cut_backbone_from(checking_nodes)
            checking_nodes.select do |node|
              cutten_backbone.any? do |key, rels|
                key.include?(node) &&
                  !rels.flat_map(&:first).all? { |n| dict.var_of(n.uniq_specie) }
              end
            end
          end
        end

      end
    end
  end
end
