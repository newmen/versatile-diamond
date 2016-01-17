module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to braket
        # @abstract
        class OpBrakets < UnaryOperator
        private

          # @return [String] joins the argument by operation
          # @override
          def apply
            "#{bra}#{argument.code}#{ket}"
          end

          # @return [String]
          def bra
            mark.to_s[0]
          end

          # @return [String]
          def ket
            mark.to_s[1]
          end
        end

      end
    end
  end
end
