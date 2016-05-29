module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Compares that all pairs of expressions are equal
        class EqualsCondition < AndCondition
          class << self
            # @param [Array] pairs
            # @param [Array] exprs
            # @return [EqualsCondition]
            def [](pairs, *exprs)
              super(pairs.map(&method(:op)), *exprs)
            end

          private

            # @param [Array] exprs
            # @return [Core::OpEq]
            def op(exprs)
              Core::OpEq[*exprs]
            end
          end
        end

      end
    end
  end
end
