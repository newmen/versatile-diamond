using RichString

class Analyzer < AnalysisTool
  class << self
    attr_reader :config_path, :line_number

    def read_config(config_path)
      @config_path = config_path
      @line_number = 0
      new(config_path).analyze
    end

    def inc_line_number
      @line_number += 1
    end
  end

  def initialize(config_path)
    @file = File.open(config_path)
    @root = nil
  end

  def analyze
    loop do
      line = next_line

puts "LINE: #{line}"

      interpret(line, method(:change_root)) do
        pass_line_to(@root, line)
      end
    end

  # rescue AnalyzingError => e
  #   puts e.message
  rescue EOFError => e
    puts "#{@config_path}: #{e.message}"
  # rescue Exception
  end

private

  def change_root(line)
    root = head_and_tail(line).first
    @root = instance(root)
  end

  def instance(name)
    component = name.constantize
    if component
      component.respond_to?(:instance) ? component.instance : component.new
    else
      syntax_error('common.undefined_component', component: name)
    end
  end

  def next_line
    Analyzer.inc_line_number
    line = @file.readline
    line.sub!(/#.+\Z/, '')
    line.rstrip!
    line != '' ? line : next_line
  end
end
