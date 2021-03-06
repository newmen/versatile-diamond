module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to round brakets
        class OpRoundBks < OpBrakets
          class << self
            # @param [Statement] expr
            # @return [OpRoundBks]
            def [](expr)
              if valid?(expr)
                super
              else
                arg_err!("Wrong argument of round brakets #{expr.inspect}")
              end
            end

          private

            # @param [Statement] expr
            # @return [Boolean]
            # @override
            def valid_expr?(expr)
              super || expr.assign?
            end
          end

          def_delegator :argument, :expr?

        private

          # @return [Symbol]
          def mark
            :'()'
          end
        end

      end
    end
  end
end
