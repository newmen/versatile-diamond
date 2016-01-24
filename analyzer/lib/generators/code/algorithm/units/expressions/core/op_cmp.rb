module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Equal operator statement
        # @abstract
        class OpCmp < BinaryOperator
          include LogicOperator

          class << self
            # @param [Array] exprs
            # @return [OpEq]
            def [](*exprs)
              if exprs.size == 2 && valid?(*exprs)
                super
              else
                raise ArgumentError, 'Passed not two or not expressions'
              end
            end
          end
        end

      end
    end
  end
end
