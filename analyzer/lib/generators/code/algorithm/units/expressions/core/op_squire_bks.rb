module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to squire brakets
        class OpSquireBks < OpBrakets
          class << self
            # @param [Expression] expr
            # @return [OpSquireBks]
            def [](expr)
              if valid?(expr)
                super
              else
                raise "Wrong argument of squire brakets #{expr.inspect}"
              end
            end

          private

            # @return [Boolean]
            # @override
            def valid_op?(expr)
              !expr.op?
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:[], *exprs)
          end
        end

      end
    end
  end
end
