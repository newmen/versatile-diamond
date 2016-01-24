module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean not operator statement
        class OpNot < UnaryOperator
          include LogicOperator

          class << self
            # @param [Expression] expr
            # @return [OpNot]
            def [](expr)
              valid?(expr) ? super : raise("Cannot negate #{expr.inspect}")
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'!', *exprs)
          end
        end

      end
    end
  end
end
