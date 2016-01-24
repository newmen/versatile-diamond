module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides methods for check the initialization values
        module InitValuesChecker
        private

          # @param [Array] value
          # @return [Boolean]
          def arr?(value)
            value.is_a?(Array)
          end

          # @param [String] value
          # @return [Boolean]
          def str?(value)
            value.is_a?(String)
          end

          # @param [String] value
          # @return [Boolean]
          def side_spaces?(value)
            str?(value) && value =~ /^\s+|\s+$/
          end

          # @param [String] value
          # @return [Boolean]
          def empty?(value)
            value.empty? || side_spaces?(value)
          end
        end

      end
    end
  end
end
