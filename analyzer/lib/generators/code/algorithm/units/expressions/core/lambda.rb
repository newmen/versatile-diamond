module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the lambda function statement
        class Lambda < Statement
          include Modules::ListsComparer
          include Expression

          class << self
            # @param [Array] defined_vars
            # @param [Array] arg_vars
            # @param [Expression] body
            # @return [Lambda]
            def [](defined_vars, *arg_vars, body)
              if !defined_vars
                arg_err!('Variables dictionary is not set')
              elsif !arg_vars.all?(&:var?)
                msg = "Wrong type of lambda argument variable #{arg_vars.inspect}"
                arg_err!(msg)
              elsif !body.expr? && !body.cond? && !body.assign? && !body.tin?
                msg = "Body #{body.inspect} must be assign or expression or condition"
                arg_err!(msg)
              else
                super
              end
            end
          end

          def_delegator :@body, :using

          # @param [Array] defined_vars
          # @param [Array] arg_vars
          # @param [Expression] body
          def initialize(defined_vars, *arg_vars, body)
            @defined_vars = defined_vars
            @arg_vars = arg_vars.freeze
            @body = body
          end

          # @return [String]
          def code
            [
              OpSquireBks[closure_vars],
              OpRoundBks[OpSequence[*@arg_vars.map(&:define_arg)]],
              OpBraces[@body]
            ].map(&:code).join
          end

          # Checks that current statement is constant
          # @return [Boolean] true
          # @override
          def const?
            true
          end

        private

          # @return [Statement]
          def closure_vars
            vars = using(@defined_vars)
            if vars.empty?
              Constant['']
            elsif lists_are_identical?(vars, @defined_vars, &:==)
              OpRef[]
            else
              OpSequence[*vars.map(&OpRef.public_method(:[]))]
            end
          end
        end

      end
    end
  end
end
