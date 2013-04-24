require 'forwardable'

class SpecificSpec
  extend Forwardable
  include ArgumentsParser
  include SyntaxChecker

  def initialize(spec_str)
    name, @options = name_and_options(spec_str)
    @spec = Spec[name]
    @options.each { |atom_keyname, _| @spec[atom_keyname] } # raise syntax error if atom_keyname undefined
  end

  def initialize_copy(other)
    @options = other.instance_variable_get('@options'.to_sym).dup
  end

  def_delegators :@spec, :[], :name

  def external_bonds
    @spec.external_bonds - @options.size
  end

  def incoherent(atom_keyname)
    if @spec[atom_keyname] # condition raise syntax_error if atom_keyname undefined
      @options[atom_keyname] = :incoherent
    end
  end

  def is_gas?
    Gas.instance.include?(@spec)
  end

  def to_s
    options = @options.map { |atom_keyname, v| "#{atom_keyname}: #{v}" }.join(', ')
    "#{@spec.to_s}(#{options})"
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
