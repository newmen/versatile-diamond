module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for all C++ expressions
        # @abstract
        class Expression < Statement

          # @param [String] value
          def initialize(value)
            @value = value.freeze
          end

          # @return [String] string with expression code
          def code
            value.code
          end

        protected

          # @return [Statement]
          def name
            Constant[@value]
          end
        end

      end
    end
  end
end
