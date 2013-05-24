require 'forwardable'

class SpecificSpec
  extend Forwardable
  include ArgumentsParser
  include SyntaxChecker

  def initialize(spec_str)
    @original_name, @options = name_and_options(spec_str)
    @spec = Spec[@original_name]
    @options.each { |atom_keyname, _| @spec[atom_keyname] } # raises syntax error if atom_keyname undefined
  end

  def initialize_copy(other)
    @options = other.instance_variable_get(:@options).dup
  end

  def_delegators :@spec, :[], :extendable?

  def name
    @original_name
  end

  def external_bonds
    @spec.external_bonds - @options.size
  end

  %w(incoherent unfixed).each do |state|
    define_method(state) do |atom_keyname|
      if @spec[atom_keyname] # condition raise syntax_error if atom_keyname undefined
        @options[atom_keyname] = state.to_sym
      end
    end
  end

  def is_gas?
    Gas.instance.include?(@spec)
  end

  def external_bonds_after_extend
    return @external_bonds_after_extend if @external_bonds_after_extend
    @extended_spec = @spec.extend_by_references
    @external_bonds_after_extend = @extended_spec.external_bonds - @options.size
  end

  def extend!
    @spec = @extended_spec
  end

  def to_s
    options = @options.map { |atom_keyname, v| "#{atom_keyname}: #{v}" }.join(', ')
    "#{@spec.to_s}(#{options})"
  end

  def visit(visitor)
    @spec.visit(visitor)
    visitor.accept_specific_spec(self)
  end

private

  def name_and_options(spec_str)
    name, args_str = Matcher.specified_spec(spec_str)
    args = string_to_args(args_str)
    options = args.empty? ? {} : args.first
    unless options && options.is_a?(Hash) && options.reject { |_, option| option == '*' }.empty?
      # TODO: checking only stars here
      syntax_error('.wrong_specification')
    end
    [name.to_sym, options]
  end
end
