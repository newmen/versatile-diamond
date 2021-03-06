module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Sequence of values operator statement
        class OpSequence < BinaryOperator
          class << self
            # @param [Array] exprs
            # @return [OpSequence]
            def [](*exprs)
              if exprs.any?(&:cond?)
                arg_err!('Conditions cannot be sequenced')
              else
                super
              end
            end
          end

        private

          # @return [Symbol]
          def mark
            :','
          end

          # @return [String]
          # @override
          def separator
            "#{mark} "
          end
        end

      end
    end
  end
end
