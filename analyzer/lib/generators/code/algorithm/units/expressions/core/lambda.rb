module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the lambda function statement
        class Lambda < Statement

          # @param [NameRemember] namer
          # @param [Array] arg_vars
          # @param [Expression] body
          def initialize(namer, *arg_vars, body)
            @namer = namer
            @arg_vars = OpRoundBks[arg_vars]
            @body = OpBraces[body]
          end

          # @return [String]
          def code
            "#{closure_vars.code}#{@arg_vars.code} #{@body.code}"
          end

        protected

          # @return [Array]
          def exprs
            [closure_vars, @arg_vars, @body]
          end

        private

          # @return [Array]
          def closure_vars
            vars = @body.using(@namer.defined_vars).map { |var| OpRef[var.name] }
            OpSquireBks[OpSequence[*vars]]
          end
        end

      end
    end
  end
end
