module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Call member over pointer operator statement
        class OpCall < BinaryOperator
          include ThinSeparator

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'->', *exprs)
          end
        end

      end
    end
  end
end
