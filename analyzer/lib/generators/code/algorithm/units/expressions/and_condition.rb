module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Joins all checking expressions by && operation
        class AndCondition < Core::Condition
          class << self
            # @param [Array] exprs
            # @param [Core::Expression] body
            # @return [EqualsCondition]
            def [](exprs, body)
              super(join(exprs), body)
            end

          private

            # @param [Array] exprs
            # @return [Core::OpAnd]
            def join(exprs)
              Core::OpAnd[*exprs]
            end
          end
        end

      end
    end
  end
end
