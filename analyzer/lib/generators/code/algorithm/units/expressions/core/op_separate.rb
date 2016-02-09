module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Values separation operator statement
        class OpSeparate < OpSequence
          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(*exprs, mark: :';')
          end
        end

      end
    end
  end
end
