module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to squire brakets
        class OpBraces < OpBrakets

          # @param [Array] exprs to which the operation will be applied
          # @option [Boolean] :multiline
          def initialize(*exprs, multiline: true)
            super(:'{}', *exprs)
            @is_multiline = multiline
          end

        private

          # @return [String]
          def space
            @is_multiline ? "\n" : ' '
          end

          # @return [String]
          # @override
          def bra
            "#{super}#{space}"
          end

          # @return [String]
          # @override
          def ket
            "#{space}#{super}"
          end
        end

      end
    end
  end
end
