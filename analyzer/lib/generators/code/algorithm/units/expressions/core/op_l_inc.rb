module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Get right increment operator statement
        class OpLInc < OpRInc
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
