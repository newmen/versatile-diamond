module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean not operator statement
        class OpNot < PrefixOperator
          class << self
            # @param [Expression] expr
            # @return [OpNot]
            def [](expr)
              if expr.expr?
                super
              else
                raise "Cannot negate #{expr.inspect}"
              end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'!', *exprs)
          end
        end

      end
    end
  end
end
