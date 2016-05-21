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
                arg_err!('Call operator requires at least two arguments')
              elsif first.var? && !first.obj?
                insp_fst = first.inspect
                msg = "First argument #{insp_fst} of call operator must be a variable"
                arg_err!(msg)
              elsif !valid?(first, *others)
                arg_err!("Wrong type of calling expressions #{others.inspect}")
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
                              !(expr.op? || expr.const? || expr.type? || expr.scalar?))
              end
            end
          end

          def_delegators :'inner_exprs.last', :expr?, :var?

          # @return [Boolean] false
          # @override
          def op?
            false
          end

        private

          # @return [Symbol]
          def mark
            :'->'
          end
        end

      end
    end
  end
end
