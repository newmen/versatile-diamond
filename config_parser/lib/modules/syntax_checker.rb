using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Modules

    # Provides method for raising syntax error
    module SyntaxChecker
      # Translates message by class name and raises syntax error exception
      # @param [String] message the message path which will be passed to
      #   translate helper
      # @param [Array] args the argument which will be passed to translate
      #   helper
      # @rescue [Errors::SyntaxError] the raised syntax error exception
      def syntax_error(message, *args)
        klass = is_a?(Class) ? self : self.class
        if message[0] == '.'
          message = "#{klass.to_s.underscore}#{message}"
        end

        raise Errors::SyntaxError.new(I18n.t(message, *args))
      end
    end

  end
end
