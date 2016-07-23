module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean AND operator statement
        class OpAnd < BinaryOperator
          include AlgebraicOperator

          class << self
            # @param [Array] exprs
            # @return [OpAnd]
            def [](*exprs)
              if valid?(*exprs)
                super
              else
                arg_err!("Cannot make chain with AND operator for #{exprs.inspect}")
              end
            end
          end

        private

          # @return [Symbol]
          def mark
            :'&&'
          end
        end

      end
    end
  end
end
