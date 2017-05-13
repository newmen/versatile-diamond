module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Less or Eq comparation operator statement
        class OpLessEq < OpLess
        private

          # @return [Symbol]
          def mark
            :<=
          end
        end

      end
    end
  end
end
