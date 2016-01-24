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

          # Checks that current statement is unreal tin operator
          # @return [Boolean] true
          # @override
          def tin?
            true
          end
        end

      end
    end
  end
end

