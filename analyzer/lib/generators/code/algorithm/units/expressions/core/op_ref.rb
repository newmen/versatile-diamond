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
              if !expr.type? && (expr.var? || expr.const?)
                super
              else
                raise "Cannot get reference of #{expr.inspect}"
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
