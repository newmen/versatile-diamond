module VersatileDiamond
  using Patches::RichString

  # Class for analyzing configuration file writen on VD:DSL
  class Analyzer < Interpreter::Base
    class << self
      # Self method for reading and analyzing configuration file
      # If the results already where obtained then using it
      #
      # @param [String] config_path the path to configuration file
      # @option [Boolean] :check_cache is flag which if true then cache will be checked
      # @return [Organizers::AnalysisResult] the result of analysis
      def read_config(config_path, check_cache: true)
        # проверяем, что уже есть резульаты анализа
        # результатов нет: анализируем и сохраняем дамп

        result = check_cache && Tools::Serializer.load(config_path)

        if result
          Tools::Config.load(config_path)
        else
          Tools::Config.init if check_cache

          content = File.open(config_path).readlines
          result = new(content, config_path).analyze
          Tools::Serializer.save(config_path, result) if check_cache
          Tools::Config.save(config_path) if check_cache
        end

        result
      end
    end

    # Initialize analyzer
    # @param [String] content the content whitch will be analyzed
    # @param [String] config_path the path to configuration file
    def initialize(content, config_path = nil)
      @content = content
      @line_number = 0
      @line = next_line
      @root = nil

      @config_path = config_path
    end

    # Prepare analysis result
    # @return [Organizers::AnalysisResult] the result of analysis
    def analyze
      read_all_lines
      grab_analysis
    rescue Errors::SyntaxError => e
      puts e.message(@config_path, @line_number)
      nil
    rescue Errors::Base
      puts "Versatile Diamond internal error at line #{@line_number}:"
      puts "\n\t#{@line.strip}" if @line
      puts
      puts "\nPlease report this error"
      raise
    end

  private

    # Launches analysis cycle
    def read_all_lines
      loop do
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
    end

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
      @line = @content[@line_number]
      @line_number += 1
      return unless @line
      @line.sub!(/#.+\Z/, '') # drop comments
      @line.rstrip!
      (!@line || @line != '') ? @line : next_line
    end

    # Grabs analysis of all collected data
    # @raise [Errors::SyntaxError] if found duplication of some reaction
    # @return [AnalysisResult] the result of analysis
    def grab_analysis
      Organizers::AnalysisResult.new
    rescue Organizers::AnalysisResult::ReactionDuplicate => e
      syntax_error('.reaction_duplicate', first: e.first, second: e.second)
    end
  end

end
