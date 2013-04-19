class SpecificSpec
  include ArgumentsParser
  include SyntaxChecker

  attr_reader :spec

  def initialize(spec_str)
    spec_name, options = name_and_options(spec_str)
    @spec = Spec[spec_name]
    @options = options
  end

  def external_bonds
    @spec.external_bonds == 0 ? 0 : @spec.external_bonds - @options.size
  end

private

  def name_and_options(spec_str)
    name, args_str = Matcher.specified_spec(spec_str)
    args = string_to_args(args_str)
    options = args.empty? ? {} : args.first
    unless options && options.is_a?(Hash) && options.reject { |_, option| option == '*' }.empty?
      # TODO: checking only star here
      syntax_error('.wrong_specification')
    end
    [name.to_sym, options]
  end
end
