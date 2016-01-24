module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Equal operator statement
        class OpEq < OpCmp

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:==, *exprs)
          end
        end

      end
    end
  end
end
