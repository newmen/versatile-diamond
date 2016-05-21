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
              expr.const? || expr.type?
            end

            # @return [Boolean]
            # @override
            def valid_op?(expr)
              super && !expr.tin?
            end
          end

        private

          # @return [Symbol]
          def mark
            :'<>'
          end

          # @return [String]
          # @override
          def inner_code
            super_code = super
            args = super_code.split(', ')
            if args.map(&:size).select { |s| s > 20 }.size > 1
              "\n" + shift(args.join(",\n")) + "\n"
            else
              super_code
            end
          end
        end

      end
    end
  end
end
