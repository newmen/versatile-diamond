module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the lambda function statement
        class Lambda < Statement
          include Modules::ListsComparer
          include Expression

          class << self
            # @param [NameRemember] namer
            # @param [Array] arg_vars
            # @param [Expression] body
            # @return [Lambda]
            def [](namer, *arg_vars, body)
              if !namer
                arg_err!('Name remember is not set')
              elsif !arg_vars.all?(&:var?)
                msg = "Wrong type of lambda argument variable #{arg_vars.inspect}"
                arg_err!(msg)
              elsif !body.expr? && !body.cond? && !body.tin?
                msg = "Lambda body #{body.inspect} must by expression or condition"
                arg_err!(msg)
              else
                super
              end
            end
          end

          def_delegator :@body, :using

          # @param [NameRemember] namer
          # @param [Array] arg_vars
          # @param [Expression] body
          def initialize(namer, *arg_vars, body)
            @namer = namer
            @arg_vars = OpRoundBks[OpSequence[*arg_vars.map(&:define_arg)]].freeze
            @body = OpBraces[body]
          end

          # @return [String]
          def code
            [closure_vars, @arg_vars, @body].map(&:code).join
          end

          # Checks that current statement is constant
          # @return [Boolean] true
          # @override
          def const?
            true
          end

          # Checks that current statement is scalar value
          # @return [Boolean] true
          # @override
          def scalar?
            true
          end

        private

          # @return [OpSquireBks]
          def closure_vars
            all_defined_vars = @namer.defined_vars
            vars = using(all_defined_vars).map(&OpRef.public_method(:[]))
            if vars.empty?
              expr = Constant['']
            elsif lists_are_identical?(vars, all_defined_vars, &:==)
              expr = OpRef[Constant['']]
            else
              expr = OpSequence[*vars.sort(&:code)]
            end
            OpSquireBks[expr]
          end
        end

      end
    end
  end
end
