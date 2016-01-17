module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the lambda function statement
        class Lambda < Statement
          include Modules::ListsComparer

          # @param [NameRemember] namer
          # @param [Array] arg_vars
          # @param [Expression] body
          def initialize(namer, *arg_vars, body)
            @namer = namer
            @arg_vars = OpRoundBks[OpSequence[*arg_vars.map(&:define_arg)]]
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
            all_defined_vars = @namer.defined_vars
            vars = @body.using(all_defined_vars).map { |var| OpRef[var.name] }
            if lists_are_identical?(vars, all_defined_vars, &:==)
              vars = [OpRel[Constant['']]]
            end
            OpSquireBks[OpSequence[*vars]]
          end
        end

      end
    end
  end
end
