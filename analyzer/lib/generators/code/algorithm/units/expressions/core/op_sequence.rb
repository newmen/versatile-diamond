module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Sequence of values peration statement
        class OpSequence < BinaryOperator

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:',', *exprs)
          end

        private

          # @return [String]
          # @override
          def separator
            "#{mark} "
          end
        end

      end
    end
  end
end
