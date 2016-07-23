module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Compares that all pairs of expressions are not equal
        class NotEqualsCondition < EqualsCondition
          class << self
          private

            # @param [Array] exprs
            # @return [Core::OpNotEq]
            # @override
            def op(exprs)
              Core::OpNotEq[*exprs]
            end
          end
        end

      end
    end
  end
end
