module VersatileDiamond
  module Modules

    module ArgumentsParser
      def string_to_args(args_str)
        return [] if !args_str || args_str == ''
        args, options = scan_args(args_str)
        args << options unless options.empty?
        args
      end

      def scan_args(args_str)
        options = {}
        args = extract_hash_args(args_str) do |key, value|
          syntax_error('common.duplicating_key', name: key) if options[key]
          options[key] = cast_value(value)
        end

        options = Hash[options.to_a.reverse]
        [args, options]
      end

      def extract_hash_args(args_str, &block)
        args = args_str.split(/\s*(?![^(]*\)),\s*/)

        key_value_rgx = /\A(?<key>[a-z][a-z0-9_]*):\s+(?<value>.+)\Z/

        loop do
          break if args.last !~ key_value_rgx
          block[$~[:key].to_sym, cast_value($~[:value])]
          args.pop
        end

        args.map do |arg|
          if arg =~ key_value_rgx
            syntax_error('common.wrong_arguments_ordering')
          end
          cast_value(arg)
        end
      end

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
