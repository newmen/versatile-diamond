module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Assign operator statements
        class Assign < Statement

          def_delegator :@var, :using

          # @param [Variable] var
          # @option [Type] :type
          # @option [Expression] :value
          def initialize(var, type: nil, value: nil)
            @var = var.freeze
            @type = type.freeze
            @value = value.freeze
          end

          # @return [String]
          def code
            if @type || @value
              @value ? "#{left_side} = #{@value.code}" : left_side
            else
              raise "Cannot assign variable #{@var} without type and value"
            end
          end

          # Checks that current statement is variable definition or assign
          # @return [Boolean] true
          # @override
          def assign?
            true
          end

        private

          # @return [String]
          def left_side
            @type ? @type.code + @var.code : @var.code
          end
        end

      end
    end
  end
end
