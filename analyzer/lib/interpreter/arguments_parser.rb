module VersatileDiamond
  module Interpreter

    # Provides methods for parsing arguments
    module ArgumentsParser

      # Parse string and returns array of arguments
      # @param [String] args_str the parsing string
      # @raise [Errors::SyntaxError] if parsing went wrong
      # @return [Array] the array of arguments
      def string_to_args(args_str)
        return [] if args_str == ''
        args, options = scan_args(args_str)
        args << options unless options.empty?
        args
      end

      # Extrancts hash arguments
      # @param [String] args_str see at #string_to_args same argument
      # @raise [Errors::SyntaxError] if arguments has wrong ordering
      # @yield [key, value] do for each extracted pair of hash
      # @return [Array] the remaining arguments
      def extract_hash_args(args_str, &block)
        args = args_str.split(/\s*(?![^(]*\)),\s*/)

        key_value_rgx = /\A(?<key>[a-z][a-z0-9_]*):\s+(?<value>.+)\Z/

        loop do
          break if args.last !~ key_value_rgx
          block[$~[:key].to_sym, cast_value($~[:value])] if block_given?
          args.pop
        end

        args.map do |arg|
          if arg =~ key_value_rgx
            syntax_error('common.wrong_arguments_ordering')
          end
          cast_value(arg)
        end
      end

    private

      # Parse arguments with separating options
      # @param [String] args_str see at #string_to_args same argument
      # @raise [Errors::SyntaxError] if has duplication of option key
      # @return [Array] there the last argument is hash of options
      def scan_args(args_str)
        options = {}
        args = extract_hash_args(args_str) do |key, value|
          syntax_error('common.duplicating_key', name: key) if options[key]
          options[key] = cast_value(value)
        end

        options = Hash[options.to_a.reverse]
        [args, options]
      end

      # Casts value to correspond type
      # @param [String] value the value as string
      # @return [Object] the casted value
      def cast_value(value)
        if value[0] == ?:
          value[1...(value.length)].to_sym
        elsif value =~ /\A(['"])([^\1]*)\1\Z/
          $2
        elsif value =~ /\A(-?\d+)\Z/
          $1.to_i
        elsif value =~ /\A(-?\d+(?:\.\d+)?(?:e-?\d+)?)\Z/
          $1.to_f
        else
          value
        end
      end
    end

  end
end
