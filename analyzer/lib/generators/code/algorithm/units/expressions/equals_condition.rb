module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Compares that all pairs of expressions are equal
        class EqualsCondition < Core::Condition
          class << self
            # @param [Array] exprs_pairs
            # @param [Core::Expression] body
            # @return [EqualsCondition]
            def [](exprs_pairs, body)
              compares = exprs_pairs.map(&method(:op))
              super(Core::OpAnd[*compares], body)
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
