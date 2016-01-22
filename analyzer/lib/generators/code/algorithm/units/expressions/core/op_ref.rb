module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Get reference operator statement
        class OpRef < PrefixOperator
          class << self
            # @param [Expression] expr
            # @return [OpRef]
            def [](expr)
              valid?(expr) ? super : raise("Cannot get reference of #{expr.inspect}")
            end

          private

            # @param [Expression] expr
            # @return [Boolean]
            def valid?(expr)
              # if var or funciton name
              expr.var? ||
                [:expr?, :const?, :scalar?, :type?, :op?, :cond?].all? do |pn|
                  !expr.public_send(pn)
                end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:&, *exprs)
          end
        end

      end
    end
  end
end
