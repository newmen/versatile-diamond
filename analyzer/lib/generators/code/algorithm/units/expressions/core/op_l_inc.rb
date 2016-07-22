module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Get left increment operator statement
        class OpLInc < UnaryOperator
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

        private

          # @return [Symbol]
          def mark
            :'++'
          end
        end

      end
    end
  end
end
