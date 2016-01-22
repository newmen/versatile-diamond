module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Unary operator statement
        # @abstract
        class UnaryOperator < Operator

          # @param [Symbol] mark the symbolic name of operation
          # @param [Array] exprs to which the operation will be applied
          def initialize(mark, *exprs)
            super(mark, 1, *exprs)
          end

        private

          # @return [String] joins the argument by operation
          def apply
            "#{mark}#{argument.code}"
          end

          # @return [Statement]
          def argument
            inner_exprs.first
          end
        end

      end
    end
  end
end
