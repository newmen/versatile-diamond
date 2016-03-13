module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides method for validate arguments of logic operators
        module AlgebraicOperator
          include Algorithm::Units::Expressions::Core::Expression

          def self.included(base)
            base.extend(ClassMethods)
          end

          module ClassMethods
            # @param [Array] exprs
            # @return [OpAnd]
            def valid?(*exprs)
              exprs.all?(&:expr?)
            end
          end
        end

      end
    end
  end
end
