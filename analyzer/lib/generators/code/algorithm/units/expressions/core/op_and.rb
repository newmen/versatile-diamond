module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean AND operator statement
        class OpAnd < BinaryOperator
          include LogicOperator

          class << self
            # @param [Array] exprs
            # @return [OpAnd]
            def [](*exprs)
              if valid?(*exprs)
                super
              else
                msg = "Cannot make chain with AND operator for #{exprs.inspect}"
                raise ArgumentError, msg
              end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'&&', *exprs)
          end
        end

      end
    end
  end
end
