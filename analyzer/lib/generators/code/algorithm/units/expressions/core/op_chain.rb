module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Chain operator statement
        # @abstract
        class OpChain < BinaryOperator
          include AlgebraicOperator

          class << self
            # @param [Array] exprs
            # @return [OpAnd]
            def [](*exprs)
              if valid?(*exprs)
                super
              else
                arg_err!("Cannot make chain with CHAIN operator for #{exprs.inspect}")
              end
            end
          end
        end

      end
    end
  end
end
