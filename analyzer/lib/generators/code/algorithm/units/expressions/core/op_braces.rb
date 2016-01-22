module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions::Core

        # Wraps the statement to squire brakets
        class OpBraces < OpBrakets
          class << self
            # @param [Expression] expr
            # @option [Boolean] :multilines
            # @option [Boolean] :ext_new_lines
            # @return [OpBraces]
            def [](expr, multilines: true, ext_new_lines: false)
              if expr.type?
                raise "Type cannot be argument of bracers #{expr.inspect}"
              elsif !multilines && ext_new_lines
                raise "Cannot have external new line when statement is not multilines"
              else
                super
              end
            end
          end

          # @param [Array] exprs to which the operation will be applied
          # @param [Hash] kwargs
          def initialize(*exprs, **kwargs)
            super(:'{}', *exprs)
            @is_multilines = kwargs[:multilines]
            @ext_new_lines = kwargs[:ext_new_lines]
          end

          # Checks that current statement is expression
          # @return [Boolean]
          def expr?
            !@is_multilines
          end

        private

          # @return [String]
          def inner_space
            expr? ? ' ' : "\n"
          end

          # @return [String]
          def start_char
            @ext_new_lines ? "\n" : (expr? ? '' : ' ')
          end

          # @return [String]
          def end_char
            @ext_new_lines ? "\n" : ''
          end

          # @return [String]
          # @override
          def bra
            "#{start_char}#{super}#{inner_space}"
          end

          # @return [String]
          # @override
          def ket
            "#{inner_space}#{super}#{end_char}"
          end

          # @return [String]
          # @override
          def inner_code
            expr? ? super : inner_lines.join("\n")
          end

          # @return [Array]
          def inner_lines
            exprs_with_methods.map { |method_name, expr| send(method_name, expr.code) }
          end

          # @return [Array]
          def exprs_with_methods
            deep_exprs.map do |expr|
              [(expr.expr? || expr.assign? ? :wrap : :shift), expr]
            end
          end

          # @return [Array]
          def deep_exprs
            argument.tin? ? argument.inner_exprs : [argument]
          end
        end

      end
    end
  end
end
