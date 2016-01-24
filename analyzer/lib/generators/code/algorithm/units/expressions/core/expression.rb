module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for all C++ expressions
        module Expression

          # Checks that current statement is expression
          # @return [Boolean] true
          # @override
          def expr?
            true
          end
        end

      end
    end
  end
end
