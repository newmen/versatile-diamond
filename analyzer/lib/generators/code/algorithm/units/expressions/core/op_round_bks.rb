module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to round brakets
        class OpRoundBks < OpBrakets

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'()', *exprs)
          end
        end

      end
    end
  end
end