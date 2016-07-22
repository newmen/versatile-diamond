module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Joins all checking expressions by || operation
        class OrCondition < AndCondition
          class << self
          private

            # @param [Array] exprs
            # @return [Core::OpOr]
            def join(exprs)
              Core::OpOr[*exprs]
            end
          end
        end

      end
    end
  end
end
