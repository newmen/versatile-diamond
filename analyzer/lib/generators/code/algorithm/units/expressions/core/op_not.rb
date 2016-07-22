module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean not operator statement
        class OpNot < UnaryOperator
          include AlgebraicOperator

          class << self
            # @param [Expression] expr
            # @return [OpNot]
            def [](expr)
              valid?(expr) ? super : arg_err!("Cannot negate #{expr.inspect}")
            end
          end

        private

          # @return [Symbol]
          def mark
            :'!'
          end
        end

      end
    end
  end
end
