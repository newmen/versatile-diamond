module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Boolean AND operator statement
        class OpAnd < BinaryOperator
          extend LogicOperator
          include Expression

          class << self
            # @param [Array] exprs
            # @return [OpAnd]
            def [](*exprs)
              if valid?(*exprs)
                super
              else
                raise "Cannot make chain with AND operator for #{exprs.inspect}"
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
