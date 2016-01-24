module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Call member over pointer operator statement
        class OpCall < BinaryOperator
          include ThinSeparator

          class << self
            # @param [Statement] first
            # @param [Array] others
            # @return [OpCall]
            def [](first, *others)
              if others.empty?
                raise 'Call operator requires at least two arguments'
              elsif !first.var?
                insp_fst = first.inspect
                raise "First argument #{insp_fst} of call operator must be a variable"
              elsif !valid?(*others)
                raise "Wrong type of calling expressions #{others.inspect}"
              else
                super
              end
            end

          private

            # @param [Array] exprs
            # @return [Boolean]
            def valid?(*exprs)
              exprs.all? do |expr|
                expr.expr? && (self == expr.class ||
                                !(expr.op? || expr.type? || expr.scalar?))
              end
            end
          end

          def_delegators :'inner_exprs.last', :expr?, :var?

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'->', *exprs)
          end

          # @return [Boolean] false
          # @override
          def op?
            false
          end
        end

      end
    end
  end
end
