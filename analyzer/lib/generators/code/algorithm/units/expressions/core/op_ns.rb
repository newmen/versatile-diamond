module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Namespace operator statement
        class OpNs < BinaryOperator
          include ThinSeparator

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'::', *exprs)
          end
        end

      end
    end
  end
end
