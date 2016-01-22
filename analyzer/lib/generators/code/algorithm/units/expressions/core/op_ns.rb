module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Namespace operator statement
        class OpNs < BinaryOperator
          include ThinSeparator

          class << self
            # @param [Statement] first
            # @param [Array] others
            # @return [OpNs]
            def [](first, *others)
              if others.empty?
                raise 'Namespace operator requires at least two arguments'
              elsif !first.type?
                insp_fst = first.inspect
                raise "First argument #{insp_fst} of namespace operator must be a type"
              elsif !valid?(*others)
                raise "Wrong type of members #{others.inspect}"
              else
                super
              end
            end

          private

            # @param [Array] exprs
            # @return [Boolean]
            def valid?(*exprs)
              exprs.all? do |expr|
                self == expr.class ||
                  (!expr.op? && (expr.var? || expr.type? ||
                    (expr.expr? && !expr.const?)))
              end
            end
          end

          def_delegators :'inner_exprs.last', :var?, :type?

          # @param [Array] exprs to which the operation will be applied
          def initialize(*exprs)
            super(:'::', *exprs)
          end

          # @return [String] joins the argument by operation
          # @override
          def code
            fixed_exprs.map(&:code).join(separator)
          end

          # @return [Boolean] false
          # @override
          def expr?
            var?
          end

          # @return [Boolean] false
          # @override
          def op?
            false
          end

        private

          # @return [Array]
          def fixed_exprs
            inner_exprs.map { |expr| expr.expr? && !expr.var? ? expr.name : expr }
          end
        end

      end
    end
  end
end
