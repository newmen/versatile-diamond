class Equation < ComplexComponent
  include Linker

  class << self
    include SyntaxChecker

    def add(str, name, aliases)
      register(build(str, name, aliases))
    end

    def register(equation)
      @equations ||= []
      @equations << equation
      equation
    end

    # TODO: unused method
    # def purge
    #   @equations.select! { |equation| equation.rate }
    # end

  private

    def build(str, name, aliases)
      sides = Matcher.equation(str)
      syntax_error('.invalid') unless sides
      source, product = sides.map do |specs|
        specs.map { |spec_str| detect_spec(spec_str, aliases) }
      end
      check_balance(source, product)
      check_compliance(source, product)
      new(source, product, name)
    end

    def detect_spec(spec_str, aliases)
      if Matcher.active_bond(spec_str)
        ActiveBond.instance
      elsif Matcher.atom(spec_str)
        AtomicSpec.new(spec_str)
      else
        name, options = Matcher.specified_spec(spec_str)
        name = name.to_sym
        if aliases && aliases[name]
          options = "(#{options})" if options
          AliasSpec.new(name, "#{aliases[name]}#{options}")
        else
          SpecificSpec.new(spec_str)
        end
      end
    end

    def check_balance(source, product)
      syntax_error('.wrong_balance') if external_bonds_sum(source) != external_bonds_sum(product)
    end

    def external_bonds_sum(specs)
      specs.map(&:external_bonds).reduce(:+)
    end

    def check_compliance(source, product, deep = 1)
      source.group_by { |spec| spec.name }.each do |_, group|
        if group.size > 1 && product.find { |spec| spec.name == group.first.name }
          syntax_error('.cannot_be_mapped', name: group.first.name)
        end
      end

      check_compliance(product, source, deep - 1) if deep > 0
    end
  end

  def initialize(source_specs, product_specs, name)
    @source, @product = source_specs, product_specs
    @name = name
  end

  def refinement(name)
    @refinements ||= []
    ref = Refinement.new(duplicate("#{@name} #{name}"))
    @refinements << ref
    nested(ref)
  end

  def incoherent(*used_atom_strs)
    used_atom_strs.each do |atom_str|
      find_spec(atom_str) { |specific_spec, atom_keyname| specific_spec.incoherent(atom_keyname) }
    end
  end

  def position(*used_atom_strs, **options)
    first_atom, second_atom = used_atom_strs.map do |atom_str|
      find_spec(atom_str) { |specific_spec, atom_keyname| specific_spec[atom_keyname] }
    end
    instance = Position[options]
    link(:@positions, first_atom, second_atom, instance, define_var: true)
  end

  %w(source product).each do |specs|
    define_method("#{specs}_gases_num") do
      instance_variable_get("@#{specs}".to_sym).map(&:is_gas?).select { |v| v }.size
    end
  end

  def entalpy=(value, reverse_too = true)
    syntax_error('.entalpy_already_set') if @entalpy
    update_attribute(:entalpy, value)
    reverse.send('entalpy=', -value, false) if reverse_too
  end

  def forward_activation=(value, prefix = :forward)
    syntax_error('.activation_already_set') if @activation
    update_attribute(:activation, value, prefix)
  end

  def reverse_activation=(value)
    reverse.send('forward_activation=', value, :reverse)
  end

  def forward_rate=(value, prefix = :forward)
    syntax_error('.rate_already_set') if @rate
    update_attribute(:rate, value, prefix)
  end

  def reverse_rate=(value)
    reverse.send('forward_rate=', value, :reverse)
  end

  def to_s
    specs_to_s = -> specs { specs.map(&:to_s).join(' + ') }
    "#{specs_to_s[@source]} = #{specs_to_s[@product]}"
  end

protected

  attr_writer :refinements

private

  def reverse
    return @reverse if @reverse
    @reverse = self.class.register(self.class.new(@product, @source, "#{@name} reverse")) # TODO: duplicate ?
    @name << ' forward'
    @reverse.refinements = @refinements
    @reverse
  end

  def duplicate(name)
    self.class.register(self.class.new(@source.map(&:dup), @product.map(&:dup), name))
  end

  def update_attribute(attribute, value, prefix = nil)
    if @refinements
      attribute = "#{prefix}_#{attribute}" if prefix
      @refinements.each { |ref| ref.equation_instance.send("#{attribute}=", value) }
    else
      instance_variable_set("@#{attribute}".to_sym, value)
    end
  end

  def define_atom(used_atom_str)
    spec_name, atom_keyname = Matcher.used_atom(used_atom_str)
    syntax_error('.undefined_used_atom') unless spec_name && atom_keyname
    [spec_name.to_sym, atom_keyname.to_sym]
  end

  def find_spec(used_atom_str)
    spec_name, atom_keyname = define_atom(used_atom_str)
    find_spec = -> specs do
      result = specs.select { |spec| spec.name == spec_name }
      syntax_error('.cannot_be_mapped', name: spec_name) if result.size > 1
      result.first
    end
    specific_spec = find_spec[@source] || find_spec[@product]
    syntax_error('.undefined_used_atom') unless specific_spec
    yield specific_spec, atom_keyname
  end
end
