module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to squire brakets
        class OpSquireBks < OpBrakets
          class << self
            # @param [Expression] expr
            # @return [OpAngleBks]
            def [](expr)
              if valid?(expr)
                super
              else
                raise "Wrong argument of squire brakets #{expr.inspect}"
              end
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
