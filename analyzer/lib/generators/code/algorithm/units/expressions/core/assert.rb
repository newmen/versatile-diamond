module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes assert statement
        class Assert < Function

          def initialize
            super('assert', 1)
          end

          # @param [Expression] expr
          # @return [Statement] string with function call expression
          # @override
          def call(expr)
            wrap(super(expr))
          end
        end

      end
    end
  end
end
