module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Assign operator statements
        class Assign < Statement
          class << self
            # @param [Variable] var
            # @option [ScalarType] :type
            # @option [Expression] :value
            # @return [Assign]
            def [](var, type: nil, value: nil)
              if !var.tin? && (var.const? || var.type? || var.assign?)
                arg_err!("Cannot define not variable #{var.inspect}")
              elsif type && !type.type?
                arg_err!("Wrong type #{type.inspect} of defining variable")
              elsif value && !value.expr?
                arg_err!("Cannot assign not value #{value.inspect}")
              elsif !type && !value
                msg = "Cannot assign variable #{var.inspect} without type and value"
                arg_err!(msg)
              elsif type && value && type.scalar? && value.scalar?
                arg_err!("Cannot assign #{value.inspect} to pointer #{type.inspect}")
              else
                super
              end
            end
          end

          def_delegator :@var, :using

          # @param [Variable] var
          # @option [ScalarType] :type
          # @option [Expression] :value
          def initialize(var, type: nil, value: nil)
            @var = var.freeze
            @type = type.freeze
            @value = value.freeze
          end

          # @return [String]
          def code
            @value ? "#{left_side} = #{@value.code}" : left_side
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
            if !@type
              @var.code
            elsif @type.ptr?
              @type.code + @var.code
            else
              "#{@type.code} #{@var.code}"
            end
          end
        end

      end
    end
  end
end
