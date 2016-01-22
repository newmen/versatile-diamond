module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to braket
        # @abstract
        class OpBrakets < UnaryOperator
          class << self
          private

            # @return [Boolean]
            def valid?(expr)
              valid_expr?(expr) || (valid_op?(expr) && valid_inner?(expr))
            end

            # @return [Boolean]
            def valid_expr?(expr)
              expr.expr?
            end

            # @return [Boolean]
            def valid_op?(expr)
              # Second check is required because the method can be overridden
              expr.op? && !expr.expr?
            end

            # @return [Boolean]
            def valid_inner?(expr)
              expr.inner_exprs.all?(&method(:valid?))
            end
          end

        private

          # @return [String] joins the argument by operation
          # @override
          def apply
            "#{bra}#{inner_code}#{ket}"
          end

          # @return [String]
          def bra
            mark.to_s[0]
          end

          # @return [String]
          def ket
            mark.to_s[1]
          end

          # @return [String]
          def inner_code
            argument.code
          end
        end

      end
    end
  end
end
