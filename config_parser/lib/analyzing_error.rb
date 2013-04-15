class AnalyzingError < SyntaxError
  attr_reader :message

  def initialize(file, line, message)
    @message = "#{message}\n\tfrom #{file}:#{line}"
  end
end
