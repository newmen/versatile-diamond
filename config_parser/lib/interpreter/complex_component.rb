module VersatileDiamond

  module Interpreter

    # Component which can contain another components
    # @abstract
    class ComplexComponent < Component

      # Interprets line and if it has indent then line is passing to
      #   nested component
      #
      # @param [String] line see at super same argument
      # @raise [Errors::SyntaxError] if line has indent and nested component
      #   doesn't set
      def interpret(line)
        @nested = nil if line !~ /\A\s/
        super do
          syntax_error('.common.wrong_hierarchy') unless @nested
          pass_line_to(@nested, line)
        end
      end

    private

      # Replace nested Component
      # @param [Component] instance of nested Component
      # @return [Component] same as param
      def nested(instance)
        @nested = instance
      end
    end

  end

end
