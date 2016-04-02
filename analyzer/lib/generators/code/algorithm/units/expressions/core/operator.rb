module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Defines C++ operator statements
        # @abstract
        class Operator < Statement

          attr_reader :inner_exprs # must be protected

          # @param [Symbol] mark the symbolic name of operation
          # @param [Array] exprs to which the operation will be applied
          def initialize(mark, *exprs)
            @mark = mark
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

        private

          attr_reader :mark

        end

      end
    end
  end
end
