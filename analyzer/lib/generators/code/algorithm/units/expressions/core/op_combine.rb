module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Joins statements without separator between them
        class OpCombine < BinaryOperator
          include ThinSeparator

          class << self
            # @param [Statement] first
            # @param [Array] others
            # @return [OpAnd]
            def [](first, *others)
              if others.empty?
                arg_err!('Combination operator requires at least two arguments')
              else
                super
              end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'', *exprs)
          end

          # @return [String]
          # @override
          def code
            oneline? ? super : multilines.join
          end

          # Checks that current statement is unreal tin operator
          # @return [Boolean] true
          # @override
          def tin?
            true
          end

        private

          # @return [Boolean]
          def oneline?
            inner_exprs.any?(&:op?) || inner_exprs.all?(&:expr?)
          end

          # @return [Array]
          def multilines
            inner_exprs.map do |expr|
              inner_code = expr.code
              expr.expr? || expr.assign? ? "#{inner_code};\n" : inner_code
            end
          end
        end

      end
    end
  end
end

