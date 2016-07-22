module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean or operator statement
        class OpOr < BinaryOperator
          include AlgebraicOperator

          class << self
            # @param [Array] exprs
            # @return [OpOr]
            def [](*exprs)
              if valid?(*exprs)
                super
              else
                arg_err!("Cannot make chain with OR operator for #{exprs.inspect}")
              end
            end
          end

        private

          # @return [Symbol]
          def mark
            :'||'
          end
        end

      end
    end
  end
end
