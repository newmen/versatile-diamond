module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Provides the footer of chunks selector algorithm
        class LateralSelectorFooterUnit
          # @param [Integer] affixes_num
          def initialize(affixes_num)
            @affixes_num = affixes_num
          end

          # @return [Expressions::Core::Statement]
          def safe_footer
            if @affixes_num == 1
              Expressions::Core::Constant[''].freeze
            else
              assert_line + return_line
            end
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
