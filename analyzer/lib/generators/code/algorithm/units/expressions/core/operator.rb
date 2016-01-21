module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Defines C++ operator statements
        # @abstract
        class Operator < Statement

          # @param [Symbol] mark the symbolic name of operation
          # @param [Integer] arity of operation
          # @param [Array] exprs to which the operation will be applied
          def initialize(mark, arity, *exprs)
            @mark = mark
            @arity = arity
            @exprs = exprs
          end

          # @return [String] the string with applying operation
          def code
            if @arity == 0 || @arity == exprs.size
              apply
            else
              raise %(Wrong number of arguments of operation "#{mark}")
            end
          end

          # Checks that current statement is operator
          # @return [Boolean] true
          # @override
          def op?
            true
          end

        protected

          # @override
          attr_reader :exprs

        private

          attr_reader :mark

          # @param [Array] vars
          # @return [Array] list of using variables
          def using(vars)
            exprs.flat_map { |expr| expr.using(vars) }
          end
        end

      end
    end
  end
end
