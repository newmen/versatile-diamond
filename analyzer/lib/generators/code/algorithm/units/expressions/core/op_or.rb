module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean or operator statement
        class OpOr < OpChain
        private

          # @return [Symbol]
          def mark
            :'||'
          end
        end

      end
    end
  end
end
