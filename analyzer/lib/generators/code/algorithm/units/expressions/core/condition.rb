module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the condition C++ statement
        class Condition < Statement
          class << self
            # @param [Expression] checking_expr
            # @param [Array] exprs
            # @return [Condition]
            def [](checking_expr, *exprs)
              if valid?(checking_expr, exprs)
                super
              else
                arg_err!("Wrong type of condition expression #{exprs.inspect}")
              end
            end

          private

            # @param [Expression] checking_expr
            # @param [Array] exprs
            # @return [Boolean]
            def valid?(checking_expr, exprs)
              checking_expr.expr? &&
                exprs.all? do |expr|
                  expr.expr? || expr.assign? || expr.cond? || expr.op?
                end
            end
          end

          # @param [Expression] checking_expr
          # @param [Expression] truth
          # @param [Expression] otherwise
          def initialize(checking_expr, truth, otherwise = nil)
            @checking_expr = OpRoundBks[checking_expr].freeze
            @truth = OpBraces[truth, ext_new_lines: true]
            @otherwise = otherwise && OpBraces[otherwise, ext_new_lines: true]
          end

          # @return [String]
          def code
            head + tail
          end

          # Checks that current statement is condition
          # @return [Boolean] true
          def cond?
            true
          end

          # @param [Array] vars
          # @return [Array]
          # @override
          def using(vars)
            inner_exprs = [@checking_expr, @truth]
            inner_exprs << @otherwise if @otherwise
            inner_exprs.flat_map { |expr| expr.using(vars) }.uniq
          end

        private

          # @return [String]
          def head
            "if #{@checking_expr.code}#{@truth.code}"
          end

          # @return [String]
          def tail
            @otherwise ? "else#{@otherwise.code}" : ''
          end
        end

      end
    end
  end
end
