module VersatileDiamond
  using Patches::RichString

  module Modules

    # Provides method for translating messages (by class name) and raising
    # syntax errors and outputs warnings
    module SyntaxChecker

      # Raises syntax error exception
      # @param [String] message the message path which will be passed to
      #   translate helper
      # @param [Array] args the argument which will be passed to translate
      #   helper
      # @rescue [Errors::SyntaxError] the raised syntax error exception
      def syntax_error(message, **args)
        raise Errors::SyntaxError.new(translate(message, **args))
      end

      # Raises syntax warning expeption
      # @param [String] message see at #syntax_error same argument
      # @param [Array] args see at #syntax_error same argument
      def syntax_warning(message, **args)
        raise Errors::SyntaxWarning.new("#{I18n.t('warning_messages.main')} " +
         "#{translate(message, **args)} " +
         "(#{I18n.t('warning_messages.skipped')})")
      end

    private

      # Extends message by underscored class name if message is begining from
      # dot
      #
      # @param [String] message see at #system_error same argument
      # @return [String] full path message
      def extend_message(message)
        klass = is_a?(Class) ? self : self.class
        message[0] == '.' ? "#{klass.to_s.underscore}#{message}" : message
      end

      # Translates message by i18n translation helper
      # @param [String] message see at #system_error same argument
      # @param [Array] args see at #system_error same argument
      # @return [String] translated message
      def translate(message, **args)
        I18n.t(extend_message(message), **args)
      end
    end

  end
end
