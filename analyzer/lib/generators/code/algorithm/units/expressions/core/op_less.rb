module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Less comparation operator statement
        class OpLess < BinaryOperator
          class << self
            # @param [Expression] a
            # @param [Expression] b
            # @return [OpLess]
            def [](a, b)
              if a.expr? && b.expr?
                super
              else
                arg_err!("Wrong type of arguments #{a.inspect} #{b.inspect}")
              end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:<, *exprs)
          end
        end

      end
    end
  end
end
