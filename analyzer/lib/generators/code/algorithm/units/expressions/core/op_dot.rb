module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Call member over dot operator statement
        class OpDot < OpCall
        private

          # @return [Symbol]
          def mark
            :'.'
          end
        end

      end
    end
  end
end
