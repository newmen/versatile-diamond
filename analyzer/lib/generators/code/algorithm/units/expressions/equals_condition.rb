module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Compares that all pairs of expressions are equal
        class EqualsCondition < AndCondition
          class << self
            # @param [Array] exprs_pairs
            # @param [Core::Expression] body
            # @return [EqualsCondition]
            def [](exprs_pairs, body)
              super(exprs_pairs.map(&method(:resort)).map(&method(:op)), body)
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
