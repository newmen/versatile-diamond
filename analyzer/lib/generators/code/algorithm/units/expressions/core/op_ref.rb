module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Get reference operator statement
        class OpRef < UnaryOperator
          include Expression

          class << self
            # @param [Expression] expr
            # @return [OpRef]
            def [](expr = nil)
              if !expr
                super()
              elsif valid?(expr)
                super
              else
                arg_err!("Cannot get reference of #{expr.inspect}")
              end
            end

          private

            # @param [Expression] expr
            # @return [Boolean]
            def valid?(expr)
              # if var or funciton name
              expr.var? || !Statement::PREDICATES.any? { |pn| expr.public_send(pn) }
            end
          end

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            exprs.empty? ? super(Constant['']) : super
          end

        private

          # @return [Symbol]
          def mark
            :&
          end
        end

      end
    end
  end
end
