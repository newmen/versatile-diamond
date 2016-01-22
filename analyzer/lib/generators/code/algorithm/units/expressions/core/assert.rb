module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes assert statement
        class Assert < FunctionCall
          def initialize
            super('assert', 1)
          end
        end

      end
    end
  end
end
