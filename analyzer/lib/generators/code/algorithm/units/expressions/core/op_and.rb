module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean and operator statement
        class OpAnd < BinaryOperator

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'&&', *exprs)
          end
        end

      end
    end
  end
end
