module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Values separation operator statement
        class OpSeparate < OpSequence
        private

          # @return [Symbol]
          def mark
            :';'
          end
        end

      end
    end
  end
end
