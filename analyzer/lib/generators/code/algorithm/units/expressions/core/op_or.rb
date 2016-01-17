module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean or operator statement
        class OpOr < BinaryOperator

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'||', *exprs)
          end
        end

      end
    end
  end
end
