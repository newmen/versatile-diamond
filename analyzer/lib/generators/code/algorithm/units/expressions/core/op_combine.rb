module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Joins statements without separator between them
        class OpCombine < BinaryOperator
          include ThinSeparator

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'', *exprs)
          end
        end

      end
    end
  end
end

