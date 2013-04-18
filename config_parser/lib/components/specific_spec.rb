class SpecificSpec
  include SyntaxChecker

  class << self
    include ArgumentsParser
    include SyntaxChecker

    def [](specified_spec_str)
      spec_name, options = scan_name_and_options(specified_spec_str)

      @cache ||= {}
      @cache[full_name(spec_name, options)] ||= new(spec_name, options)
    end

  private

    def full_name(spec_name, options)
      options_str = options.map { |k, v| "#{k}: #{v}" }.join
      "#{spec_name}(#{options_str})"
    end

    def scan_name_and_options(specified_spec_str)
      name, args_str = Matcher.specified_spec(specified_spec_str)
      args = string_to_args(args_str)
      options = args.empty? ? {} : args.first
      unless options && options.is_a?(Hash) && options.reject { |_, option| option == '*' }.empty?
        # TODO: checking only star here
        syntax_error('.wrong_specification')
      end
      [name.to_sym, options]
    end
  end

  attr_reader :spec

  def initialize(spec_name, options)
    @spec = Spec[spec_name]
    @options = options
  end

  # TODO: unused method
  # def external_bonds
  #   @spec.external_bonds - @options.size
  # end
end
