module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Provides base operations for C++ expressions of functions
        class Function < Constant

          # @param [String] name
          # @param [Integer] arity
          # @param [Integer] template_arity
          def initialize(name, arity, template_arity = 0)
            super(name)
            @arity = arity.freeze
            @template_arity = template_arity.freeze
          end

          # @param [Array] arg_exprs
          # @option [Array] :template_arg_exprs
          # @return [Statement] string with function call expression
          def call(*arg_exprs, template_arg_exprs: [])
            if arg_exprs.size == @arity
              full_name + OpRoundBks[OpSequence[*arg_exprs.map(&:name)]]
            else
              raise ArgumentError, "Wrong number of arguments to call #{self} method"
            end
          end

        private

          # @param [Array] template_arg_exprs
          # @return [Statement] name with template arguments if them are presented
          def full_name(template_arg_exprs)
            if template_arg_exprs.size != @template_arity
              msg = "Wrong number of template arguments to call #{self} method"
              raise ArgumentError, msg
            elsif @template_arity > 0
              name + OpAngleBks[OpSequence[*template_arg_exprs.map(&:name)]]
            else
              name
            end
          end
        end

      end
    end
  end
end
