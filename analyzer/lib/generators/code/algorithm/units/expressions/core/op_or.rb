module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean or operator statement
        class OpOr < BinaryOperator
          include LogicOperator

          class << self
            # @param [Array] exprs
            # @return [OpOr]
            def [](*exprs)
              if valid?(*exprs)
                super
              else
                raise "Cannot make chain with OR operator for #{exprs.inspect}"
              end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'||', *exprs)
          end
        end

      end
    end
  end
end
