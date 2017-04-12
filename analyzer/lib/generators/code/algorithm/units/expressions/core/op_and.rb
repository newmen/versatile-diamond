module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean AND operator statement
        class OpAnd < OpChain
        private

          # @return [Symbol]
          def mark
            :'&&'
          end
        end

      end
    end
  end
end
