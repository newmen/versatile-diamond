module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the condition C++ statement
        class Condition < Statement

          # @param [Expression] checking_expr
          # @param [Expression] truth
          # @param [Expression] otherwise
          def initialize(checking_expr, truth, otherwise = nil)
            @checking_expr = OpRoundBks[checking_expr]
            @truth = OpBraces[truth]
            @otherwise = otherwise && OpBraces[otherwise]

            @_exprs = nil
          end

          # @return [String]
          def code
            "#{wrap(head + tail).chop.chop}\n"
          end

        protected

          # @return [Array]
          def exprs
            @_exprs ||= [@checking_expr, @truth, @otherwise].compact
          end

        private

          # @return [String]
          def head
            "if #{@checking_expr.code} #{@truth.code}"
          end

          # @return [String]
          def tail
            @otherwise ? " else #{@otherwise.code}" : ''
          end
        end

      end
    end
  end
end
