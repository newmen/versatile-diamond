module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Algebraic MULTIPLE operator statement
        class OpMul < OpChain
        private

          # @return [Symbol]
          def mark
            :*
          end
        end

      end
    end
  end
end
