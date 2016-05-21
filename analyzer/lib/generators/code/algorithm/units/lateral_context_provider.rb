module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The context for units of lateral find algoritnm builder
        class LateralContextProvider < ReactionContextProvider
          # @return [Array]
          def key_nodes
            key_nodes_lists.reduce(:+).reject(&:side?).uniq
          end

          # @return [Array]
          def side_nodes
            side_nodes_lists.reduce(:+).select(&:side?).uniq
          end
        end

      end
    end
  end
end
