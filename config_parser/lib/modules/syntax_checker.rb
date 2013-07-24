using VersatileDiamond::Patches::RichString

module VersatileDiamond

  module Modules

    module SyntaxChecker
      def syntax_error(*args)
        klass = is_a?(Class) ? self : self.class
        message = args.shift
        if message[0] == '.'
          message = "#{klass.to_s.split('::').last.underscore}#{message}"
        end

        raise Errors::SyntaxError.new(I18n.t(message, *args))
      end
    end

  end

end
