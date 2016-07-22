module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Overrides default separator value for operators
        module ThinSeparator
        private

          # @return [String]
          # @override
          def separator
            mark.to_s
          end
        end

      end
    end
  end
end
