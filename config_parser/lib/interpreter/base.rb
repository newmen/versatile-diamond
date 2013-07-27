module VersatileDiamond
  module Interpreter

    # The base interpreter class
    # @abstract
    class Base
      include Modules::ArgumentsParser
      include Modules::SyntaxChecker

      # Interprets the line, checking it for indent. If the indentation was
      # then call second passed function. Otherwise, perform block when passed
      # directly
      #
      # @params [String] line of configuration file
      # @params [Proc] zero_level_func function which will be called if line
      #   havent indent
      # @yield interpret the block which calling if exist a nested component
      # @raise [Errors::SyntaxError] then incorrect when line with indent
      #   and block has not given
      def interpret(line, zero_level_func, &block)
        if !has_indent?(line)
          zero_level_func[line]
        else
          block_given? ? block[line] : syntax_error('common.wrong_hierarchy')
        end
      end

      # Line cuts on the head and tail
      # @param [String] line of configuration file whitout indent
      # @return [Array] the head as first and the tail as second
      def head_and_tail(line)
        line.split(/\s+/, 2)
      end

      # Cause the passed component to interpret line, reducing it indent before
      # @param [Component] component which will be interpret decreased line
      # @param [String] line is decreasing line
      def pass_line_to(component, line)
        component.interpret(decrease_indent(line))
      end

    private

      # Checks a line for indent, and also checks that the correct indentation.
      # If the indent is not valid, throws a syntax error.
      # The correct indentation is 2 spaces or tabs.
      #
      # @param [String] line of configuration file
      # @raise [Errors::SyntaxError] when indent is incorrect
      # @return [Boolean] line has a indent?
      def has_indent?(line)
        match = line.scan(/\A(\t|  )?(.+)\Z/).first
        syntax_error('common.extra_space') if $2 && $2[0] == ' ' && $2[1] != ' '
        !!match.first
      end

      # Decreases the indent of passed line
      # @param [String] line which will be decreased
      # @return [String] line without indent
      def decrease_indent(line)
        line[0] == "\t" ? line[0] = '' : line[0..1] = ''
        line
      end
    end

  end
end
