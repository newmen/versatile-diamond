module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Algebraic MINUS operator statement
        class OpMinus < BinaryOperator
          include AlgebraicOperator

          class << self
            # @param [Array] exprs
            # @return [OpMinus]
            def [](*exprs)
              if valid?(*exprs)
                super
              else
                arg_err!("Cannot make chain with MINUS operator for #{exprs.inspect}")
              end
            end
          end

        private

          # @return [Symbol]
          def mark
            :-
          end
        end

      end
    end
  end
end
