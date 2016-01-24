module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to angle brakets
        class OpAngleBks < OpBrakets
          class << self
            # @param [Expression] expr
            # @return [OpAngleBks]
            def [](expr)
              if valid?(expr)
                super
              else
                arg_err!("Wrong argument of angle brakets #{expr.inspect}")
              end
            end

          private

            # @return [Boolean]
            # @override
            def valid_expr?(expr)
              expr.scalar? || expr.type?
            end

            # @return [Boolean]
            # @override
            def valid_op?(expr)
              super && !expr.tin?
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'<>', *exprs)
          end
        end

      end
    end
  end
end
