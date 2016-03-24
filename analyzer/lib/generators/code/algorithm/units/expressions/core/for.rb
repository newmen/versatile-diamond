module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Makes the for loop statement
        class For < Statement
          class << self
            # @param [Assign] assign
            # @param [BinaryOperator] cond
            # @param [UnaryOperator] op
            # @param [Expression] body
            # @return [For]
            def [](assign, cond, op, body)
              if !assign.assign?
                arg_err!("First argument of for loop should to be assing operation")
              elsif !cond.op?
                arg_err!("Second argument of for loop should to be condition")
              elsif !op.op?
                arg_err!("Last argument of for loop should to be operation")
              elsif !body.expr? && !body.assign? && !body.cond? && !body.tin?
                arg_err!("Incorrect expression #{body.inspect} for loop body")
              else
                super
              end
            end
          end

          def_delegator :@body, :using

          # @param [Assign] assign
          # @param [BinaryOperator] cond
          # @param [UnaryOperator] op
          # @param [Expression] body
          def initialize(assign, cond, op, body)
            @args = [assign, cond, op].map(&:freeze).freeze
            @body = body
          end

          # @return [String]
          def code
            'for ' + [
              OpRoundBks[OpSeparate[*@args]],
              OpBraces[@body, ext_new_lines: true]
            ].map(&:code).join
          end
        end

      end
    end
  end
end
