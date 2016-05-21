module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Equal operator statement
        class OpNotEq < OpCmp
        private

          # @return [Symbol]
          def mark
            :'!='
          end
        end

      end
    end
  end
end
