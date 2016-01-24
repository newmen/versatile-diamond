module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes assert statement
        class Assert < FunctionCall
          class << self
          # @param [Expression] expr
            # @return [Assert]
            def [](expr)
              if expr.expr?
                new(expr)
              else
                arg_err!("Not condition #{expr.inspect} cannot be asserted")
              end
            end
          end

          # @param [Expression] expr
          def initialize(expr)
            super('assert', expr)
          end
        end

      end
    end
  end
end
