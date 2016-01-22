module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to round brakets
        class OpRoundBks < OpBrakets
          class << self
            # @param [Expression] expr
            # @return [OpRoundBks]
            def [](expr)
              if valid?(expr)
                super
              else
                raise "Wrong argument of round brakets #{expr.inspect}"
              end
            end
          end

          def_delegator :argument, :expr?

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'()', *exprs)
          end
        end

      end
    end
  end
end
