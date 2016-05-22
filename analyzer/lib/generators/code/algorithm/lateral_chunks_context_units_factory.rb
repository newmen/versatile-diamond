module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for some of lateral find algorithm
        # @abstract
        class LateralChunksContextUnitsFactory < BaseContextUnitsFactory
          # @param [Array] nodes for which the unit will be maked
          # @return [Units::ContextReactionUnit]
          def action_unit(nodes)
            Units::ActionTargetUnit.new(context, pure_unit(nodes))
          end

          # @param [Array] nodes for which the unit will be maked
          # @return [Units::ContextReactionUnit]
          def unit(nodes)
            inner_unit = pure_unit(nodes)
            Units::ContextLateralUnit.new(dict, pure_factory, context, inner_unit)
          end
        end

      end
    end
  end
end
