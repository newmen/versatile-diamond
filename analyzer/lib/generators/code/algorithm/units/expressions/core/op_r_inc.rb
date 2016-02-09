module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Get left increment operator statement
        class OpRInc < UnaryOperator
          include Expression

          class << self
            # @param [Expression] expr
            # @return [OpRInc]
            def [](expr)
              if expr.var?
                super
              else
                arg_err!("Cannot increment non scalar variable #{expr.inspect}")
              end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'++', *exprs)
          end
        end

      end
    end
  end
end
