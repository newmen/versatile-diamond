module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Binary operator statement
        # @abstract
        class BinaryOperator < Operator

          # @param [Symbol] mark the symbolic name of operation
          # @param [Array] exprs to which the operation will be applied
          def initialize(mark, *exprs)
            super(mark, *rectify(exprs))
          end

          # @return [String] joins the argument by operation
          def code
            inner_exprs.map(&:code).join(separator)
          end

        private

          # @return [String] by which expressions will be joined
          def separator
            " #{mark} "
          end

#
# Originaly we're have next ordering of combinig expressions:
#
# one + (two + (thr + four)) + five + six =
#   which is equal to:
#
# OpCombine[OpCombine[OpCombine[one, OpCombine[two, OpCombine[thr, four]]], five], six]
#
# Expressions restification result
# Iterations:
#
# 1. [] : [OpCombine[one, OpCombine[two, OpCombine[thr, four]]], five, six]
# 2. [] : [one, OpCombine[two, OpCombine[thr, four]], five, six]
# 3. [one] : [OpCombine[two, OpCombine[thr, four]], five, six]
# 4. [one] : [two, OpCombine[thr, four], five, six]
# 5. [one, two] : [OpCombine[thr, four], five, six]
# 6. [one, two] : [thr, four, five, six]
# ...
# [one, two, thr, four, five, six]
#
          # @param [Array] combining_exprs
          # @return [Array]
          def rectify(combining_exprs)
            exprs_dup = combining_exprs.dup
            result = []
            until exprs_dup.empty?
              expr = exprs_dup.shift
              if expr.class == self.class
                expr.inner_exprs.reverse_each(&exprs_dup.method(:unshift))
              else
                result << expr
              end
            end
            result
          end
        end

      end
    end
  end
end
