module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Get right increment operator statement
        class OpRInc < OpLInc
          # @return [String]
          # @override
          def code
            "#{argument.code}#{mark}"
          end
        end

      end
    end
  end
end
