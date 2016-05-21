module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Defines C++ operator statements
        # @abstract
        class Operator < Statement

          attr_reader :inner_exprs # must be protected

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            @inner_exprs = exprs
          end

          # Checks that current statement is operator
          # @return [Boolean] true
          # @override
          def op?
            true
          end

          # @param [Array] vars
          # @return [Array] list of using variables
          def using(vars)
            inner_exprs.flat_map { |expr| expr.using(vars) }.uniq
          end
        end

      end
    end
  end
end
