module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Return operator statements
        class Return < Statement
          class << self
            # @param [Expression] expr
            # @return [Return]
            def [](expr)
              if expr.expr?
                super
              else
                arg_err!("Cannot return not expression #{expr.inspect}")
              end
            end
          end

          def_delegator :@expr, :using

          # @param [Expression] expr
          def initialize(expr)
            @expr = expr.freeze
          end

          # @return [String]
          def code
            "return #{@expr.code}"
          end

          # Checks that current statement is variable definition or assign
          # @return [Boolean] true
          # @override
          def assign?
            true
          end
        end

      end
    end
  end
end
