using VersatileDiamond::Patches::RichString

module VersatileDiamond

  class Analyzer < Interpreter::Base
    class << self
      def read_config(config_path)
        content = File.open(config_path).readlines
        new(content, config_path).analyze
      end
    end

    def initialize(content, config_path = nil)
      @content = content
      @line_number = 0
      @line = @content[0]
      @root = nil

      @config_path = config_path
    end

    def analyze
      loop do
  puts "LINE #{@line_number + 1}: #{@line}"

        interpret(@line, method(:change_root)) do
          pass_line_to(@root, @line)
        end

        next_line || break
      end

    rescue Errors::SyntaxError => e
# p Tools::Chest.instance_variable_get(:@sac).keys
      puts e.message(@line_number + 1, @config_path)
    end

  private

    def change_root(decreased_line)
      root = head_and_tail(decreased_line).first
      @root = instance(root)
    end

    def instance(name)
      component = name.constantize
      if component
        component.new
      else
        syntax_error('common.undefined_component', component: name)
      end
    end

    def next_line
      @line_number += 1
      @line = @content[@line_number]
      @line.sub!(/#.+\Z/, '') # drop comments
      @line.rstrip!
      (!@line || @line != '') ? @line : next_line
    end
  end

end
