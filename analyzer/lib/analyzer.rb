module VersatileDiamond
  using Patches::RichString

  # Class for analyzing configuration file writen on VD:DSL
  class Analyzer < Interpreter::Base
    class << self
      # Self method for reading and analyzing configuration file
      # @param [String] config_path the path to configuration file
      # @return [Boolean] finds any errors or not
      def read_config(config_path)
        content = File.open(config_path).readlines
        new(content, config_path).analyze
      end
    end

    # Initialize analyzer
    # @param [String] content the content whitch will be analyzed
    # @param [String] config_path the path to configuration file
    def initialize(content, config_path = nil)
      @content = content
      @line_number = 0
      @line = @content[0]
      @root = nil

      @config_path = config_path
    end

    # Launches analysis cycle
    # @return [Boolean] the result of analysis
    def analyze
      loop do
  # puts "LINE #{@line_number + 1}: #{@line}"

        interpret(@line, method(:change_root)) do
          begin
            pass_line_to(@root, @line)
          rescue Errors::SyntaxWarning => e
            puts e.message(@config_path, @line_number + 1)
            next_line || break
            retry
          end
        end

        next_line || break
      end

      begin
        Tools::Shunter.organize_dependecies!
      rescue Tools::Shunter::ReactionDuplicate => e
        syntax_error('.reaction_duplicate', first: e.first, second: e.second)
      end

      true
    rescue Errors::SyntaxError => e
      puts e.message(@config_path, @line_number + 1)
      false
    rescue Errors::Base
      puts "Versatile Diamond internal error at line #{@line_number + 1}:"
      puts "\n\t#{@line.strip}" if @line
      raise
    end

  private

    # Changes instance root variable which will be receive next shifted lines
    # @param [String] decreased_line the line for analyzing without forward
    #   extra spaces
    # @raise [Errors::SyntaxError] if instance of root cannot be instanced
    def change_root(decreased_line)
      root = head_and_tail(decreased_line).first
      @root = instance(root)
    end

    # Makes an anstance of interpreter
    # @param [String] name the underscored name of interpreter class
    # @raise [Errors::SyntaxError] if interpreter component cannot be instanced
    def instance(name)
      component = name.constantize
      if component
        component.new
      else
        syntax_error('common.undefined_component', component: name)
      end
    end

    # Iterate next line and cut comments
    # @return [String] the next line of content
    def next_line
      @line_number += 1
      @line = @content[@line_number]
      return unless @line
      @line.sub!(/#.+\Z/, '') # drop comments
      @line.rstrip!
      (!@line || @line != '') ? @line : next_line
    end
  end

end
