module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides the footer of chunks selector algorithm
        class LateralSelectorFooterUnit
          # @return [Expressions::Core::Statement]
          def safe_footer
            assert_line + return_line
          end

        private

          # @return [Expressions::Core::Assert]
          def assert_line
            Expressions::Core::Assert[Expressions::Core::Constant['false']]
          end

          # @return [Expressions::Core::Assert]
          def return_line
            Expressions::Core::Return[Expressions::Core::Constant['nullptr']]
          end
        end

      end
    end
  end
end
