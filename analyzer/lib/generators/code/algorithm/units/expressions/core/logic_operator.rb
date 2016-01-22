module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides method for validate arguments of logic operators
        module LogicOperator

          # @param [Array] exprs
          # @return [OpAnd]
          def valid?(*exprs)
            exprs.all?(&:expr?)
          end
        end

      end
    end
  end
end
