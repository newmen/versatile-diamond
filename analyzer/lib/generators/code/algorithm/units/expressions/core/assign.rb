module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Assign operator statements
        class Assign < Statement

          # @param [Variable] var
          # @option [Type] :type
          # @option [Expression] :value
          def initialize(var, type: nil, value: nil)
            @var = var
            @type = type
            @value = value
          end

          # @return [String]
          def code
            if @type || @value
              @value ? "#{left_side} = #{@value.code}" : left_side
            else
              raise "Cannot assign variable #{@var} without type and value"
            end
          end

        private

          def_delegator :@var, :using

          # @return [String]
          def left_side
            @type ? @type.code + @var.code : @var.code
          end
        end

      end
    end
  end
end
