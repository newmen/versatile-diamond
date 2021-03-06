module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Assign operator statements
        class Assign < Statement
          extend InitValuesChecker

          class << self
            # @param [Variable] var
            # @option [ScalarType] :type
            # @option [Expression] :value
            # @return [Assign]
            def [](var, type: nil, value: nil, constructor_args: nil)
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
              elsif value && constructor_args
                msg = "Cannot define variable #{var.inspect}"
                msg += " with value and constructor arguments"
                arg_err!(msg)
              elsif constructor_args && !type
                msg = "Cannot call constructor of #{var.inspect} without type"
                arg_err!(msg)
              elsif constructor_args && type.scalar?
                msg = "Cannot define scalar #{var.inspect} with constructor arguments"
                arg_err!(msg)
              elsif constructor_args && !call_args?(constructor_args)
                msg = "Invalid arguemnts #{args.inspect} of #{name} constructor call"
                arg_err!(msg)
              else
                super
              end
            end
          end

          # @param [Variable] var
          # @option [ScalarType] :type
          # @option [Expression] :value
          def initialize(var, type: nil, value: nil, constructor_args: nil)
            @var = var.freeze
            @type = type && type.freeze
            @value = value && value.freeze

            if constructor_args
              seq = OpSequence[*constructor_args]
              @constructor_tail = OpRoundBks[seq].freeze
            else
              @constructor_tail = nil
            end
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

          # @param [Array] vars
          # @return [Array] list of using variables
          def using(vars)
            used_vars = @var.using(vars)
            used_vars + tail_using(vars - used_vars)
          end

        private

          # @param [Array] vars
          # @return [Array]
          def tail_using(vars)
            if @value
              @value.using(vars)
            elsif @constructor_tail
              @constructor_tail.using(vars)
            else
              []
            end
          end

          # @return [String]
          def left_side
            if !@type
              @var.code
            elsif @type.ptr?
              @type.code + @var.code
            elsif @constructor_tail
              "#{type_with_var}#{@constructor_tail.code}"
            else
              type_with_var
            end
          end

          # @return [String]
          def type_with_var
            "#{@type.code} #{@var.code}"
          end
        end

      end
    end
  end
end
