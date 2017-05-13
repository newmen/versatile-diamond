module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Algebraic MINUS operator statement
        class OpMinus < OpChain
        private

          # @return [Symbol]
          def mark
            :-
          end
        end

      end
    end
  end
end
