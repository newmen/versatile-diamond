using VersatileDiamond::RichString

module VersatileDiamond

  module SyntaxChecker
    def syntax_error(*args)
      klass = is_a?(Class) ? self : self.class
      message = args.shift
      if message[0] == '.'
        message = "#{klass.to_s.split('::').last.underscore}#{message}"
      end

      raise AnalyzingError.new(
        Analyzer.config_path, Analyzer.line_number, I18n.t(message, *args))
    end
  end

end
