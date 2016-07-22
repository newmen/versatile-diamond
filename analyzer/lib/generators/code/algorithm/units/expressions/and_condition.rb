module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Joins all checking expressions by && operation
        class AndCondition < Core::Condition
          class << self
            # @param [Array] checks
            # @param [Array] exprs
            # @return [EqualsCondition]
            def [](checks, *exprs)
              super(join(resort(checks)), *exprs)
            end

          private

            # @param [Array] checks
            # @return [Array]
            def resort(checks)
              checks.sort_by(&:code)
            end

            # @param [Array] checks
            # @return [Core::OpAnd]
            def join(checks)
              Core::OpAnd[*checks]
            end
          end
        end

      end
    end
  end
end
