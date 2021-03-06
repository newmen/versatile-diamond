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

          # @return [String]
          # @override
          def code
            oneline? ? super : multilines.join("\n")
          end

          # Checks that current statement is unreal tin operator
          # @return [Boolean] true
          # @override
          def tin?
            true
          end

        private

          # @return [Symbol]
          def mark
            :''
          end

          # @return [Boolean]
          def oneline?
            inner_exprs.any?(&:op?)
          end

          # @return [Array]
          def multilines
            inner_exprs.map do |expr|
              inner_code = expr.code.rstrip
              expr.terminating? ? terminate(inner_code) : inner_code
            end
          end
        end

      end
    end
  end
end

