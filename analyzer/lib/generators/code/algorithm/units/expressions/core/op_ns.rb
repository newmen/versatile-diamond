module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Namespace operator statement
        class OpNs < BinaryOperator
          include ThinSeparator
          include Callable

          class << self
            # @param [Statement] first
            # @param [Array] others
            # @return [OpNs]
            def [](first, *others)
              if others.empty?
                arg_err!('Namespace operator requires at least two arguments')
              elsif !first.type?
                insp_fst = first.inspect
                msg = "First argument #{insp_fst} of namespace operator must be a type"
                arg_err!(msg)
              elsif !valid?(*others)
                arg_err!("Wrong type of members #{others.inspect}")
              else
                super
              end
            end

          private

            # @param [Array] exprs
            # @return [Boolean]
            def valid?(*exprs)
              exprs.all? { |expr| self == expr.class || !expr.op? }
            end
          end

          def_delegators :'inner_exprs.last', :expr?, :type?

          # @return [String] joins the argument by operation
          # @override
          def code
            inner_exprs.map(&:code).join(separator)
          end

          # @return [Boolean] false
          # @override
          def op?
            false
          end

        private

          # @return [Symbol]
          def mark
            :'::'
          end
        end

      end
    end
  end
end
