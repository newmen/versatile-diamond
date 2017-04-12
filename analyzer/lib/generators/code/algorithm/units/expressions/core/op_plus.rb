module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Algebraic PLUS operator statement
        class OpPlus < OpChain
        private

          # @return [Symbol]
          def mark
            :+
          end
        end

      end
    end
  end
end
