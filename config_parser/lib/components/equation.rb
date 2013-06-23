module VersatileDiamond

  class Equation < ComplexComponent
    include AtomMatcher
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

      def visit_all(visitor)
        @equations.each { |equation| equation.visit(visitor) }
      end

    private

      def build(str, name, aliases)
        sides = Matcher.equation(str)
        syntax_error('.invalid') unless sides
        source, products = sides.map do |specs|
          specs.map { |spec_str| detect_spec(spec_str, aliases) }
        end

        check_balance(source, products) do |ext_src, ext_prd|
          source, products = ext_src, ext_prd
        end || syntax_error('.wrong_balance')

        check_compliance(source, products)

# atom_mapping(source, products)

        new(source, products, name)
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

      def external_bonds_sum(specs)
        specs.map(&:external_bonds).reduce(:+)
      end

      def extends_if_possible(type, source, products, bonds_sum_limit, deep, &block)
        specs = eval(type.to_s)
        combinations = specs.size.times.reduce([]) { |acc, i| acc + specs.combination(i + 1).to_a }
        combinations.each do |combination|
          bonds_sum = specs.reduce(0) do |acc, spec|
            acc + (combination.include?(spec) && spec.extendable? ?
              spec.external_bonds_after_extend :
              spec.external_bonds)
          end

          if bonds_sum >= bonds_sum_limit
            duplicate_specs = specs.map do |spec|
              spec.extend! if combination.include?(spec) && spec.extendable?
              spec
            end

            args = type == :source ? [duplicate_specs, products] : [source, duplicate_specs]
            result = check_balance(*args, deep - 1, &block)
            if result then return result else next end
          end
        end
        false
      end

      # TODO: if checks every possible extending way for complete condition then analyzer may accept incorrect equation
      def check_balance(source, products, deep = 2, &block)
        ebs = external_bonds_sum(source)
        ebp = external_bonds_sum(products)

        if ebs == ebp
          block[source, products]
          true
        elsif deep > 0
          if ebs < ebp
            extends_if_possible(:source, source, products, ebp, deep, &block)
          elsif ebs > ebp
            extends_if_possible(:products, source, products, ebs, deep, &block)
          end
        else
          false
        end
      end

      def check_compliance(source, products, deep = 1)
        source.group_by { |spec| spec.name }.each do |_, group|
          if group.size > 1 && products.find { |spec| spec.name == group.first.name }
            syntax_error('.cannot_be_mapped', name: group.first.name)
          end
        end

        check_compliance(products, source, deep - 1) if deep > 0
      end

      def atom_mapping(source, products)
        has_termination_spec = -> do
          check = -> specific_spec { specific_spec.is_a?(TerminationSpec) || specific_spec.spec.simple? }
          source.find(&check) || products.find(&check)
        end

        is_full_corresponding = -> do
          source_dup, products_dup = source.dup, products.dup
          source_dup.reduce(true) do |acc, source_spec|
            i = products_dup.index { |product_spec| source_spec.name == product_spec.name }
            acc && i && products_dup.delete_at(i)
          end
        end

        if has_termination_spec.call
          # ...
        elsif source.size == products.size && is_full_corresponding.call
          # find concrete atom for each pair of source and product specs
          # TODO: it doing like simplification of specific specis tree
        else
          args = [source, products].map do |specs|
            specs.map { |specific_spec| specific_spec.spec.links }
          end

          begin
            HanserRecursiveAlgorithm.atom_mapping(*args)
          rescue HanserRecursiveAlgorithm::CannotMap
            syntax_error('.atom_mapping.cannot_map')
          rescue ArgumentError
            syntax_error('.atom_mapping.argument_error')
          end
        end
      end

      def define_property_setter(property)
        define_method("forward_#{property}=") do |value, prefix = :forward|
          syntax_error(".#{property}_already_set") if instance_variable_get("@#{property}".to_sym)
          update_attribute(property, value, prefix)
        end

        define_method("reverse_#{property}=") do |value|
          reverse.send("forward_#{property}=", value, :reverse)
        end
      end
    end

    attr_reader :name, :source, :products

    def initialize(source_specs, products_specs, name)
      @source, @products = source_specs, products_specs
      @name = name
    end

    def refinement(name)
      nest_refinement(duplicate(name))
    end

    %w(incoherent unfixed).each do |state|
      define_method(state) do |*used_atom_strs|
        used_atom_strs.each do |atom_str|
          find_spec(atom_str, find_type: :all) do |specific_spec, atom_keyname|
            specific_spec.send(state, atom_keyname)
          end
        end
      end
    end

    def position(*used_atom_strs, **options)
      first_atom, second_atom = used_atom_strs.map do |atom_str|
        find_spec(atom_str) { |specific_spec, atom_keyname| specific_spec[atom_keyname] }
      end
      link(:@positions, first_atom, second_atom, Position[options])
    end

    def lateral(env_name, **target_refs)
      @laterals ||= {}
      if @laterals[env_name]
        syntax_error('.lateral_already_connected')
      else
        environment = Environment[env_name]
        resolved_target_refs = target_refs.map do |target_alias, used_atom_str|
          syntax_error('.undefined_target_alias', name: target_alias) unless environment.is_target?(target_alias)
          atom = find_spec(used_atom_str) { |specific_spec, atom_keyname| specific_spec[atom_keyname] }
          [target_alias, atom]
        end

        @laterals[env_name] = Lateral.new(environment, Hash[resolved_target_refs])
      end
    end

    def there(*names)
      concrete_wheres = names.map do |name|
        laterals_with_where = @laterals.select { |_, lateral| lateral.has_where?(name) }.values

        syntax_error('where.undefined', name: name) if laterals_with_where.size < 1
        syntax_error('.multiple_wheres', name: name) if laterals_with_where.size > 1

        laterals_with_where.first.concretize_where(name)
      end

      name_tail = concrete_wheres.map(&:description).join(' and ')
      nest_refinement(lateralized_duplicate(concrete_wheres, name_tail))
    end

    # another methods

    %w(source products).each do |specs|
      define_method("#{specs}_gases_num") do
        instance_variable_get("@#{specs}".to_sym).map(&:is_gas?).select { |v| v }.size
      end
    end

    def enthalpy=(value)
      self.forward_enthalpy = value
      self.reverse_enthalpy = -value
    end

    define_property_setter :activation
    define_property_setter :rate

    def to_s
      specs_to_s = -> specs { specs.map(&:to_s).join(' + ') }
      "#{specs_to_s[@source]} = #{specs_to_s[@products]}"
    end

    def visit(visitor)
      if @rate
        (@source + @products).each { |spec| spec.visit(visitor) }
        yield if block_given?
        visitor.accept_equation(self)
      end
    end

  protected

    attr_writer :refinements

  private

    define_property_setter :enthalpy

    def nest_refinement(equation)
      @refinements ||= []
      @refinements << (refinement = Refinement.new(equation))
      nested(refinement)
    end

    def reverse_params
      [@products, @source, "#{@name} reverse"] # TODO: duplicate products and source?
    end

    def reverse
      return @reverse if @reverse
      @reverse = Equation.register(self.class.new(*reverse_params))
      @name << ' forward'
      @reverse.refinements = @refinements
      @reverse
    end

    def duplication_params(equation_name_tail)
      [@source.map(&:dup), @products.map(&:dup), "#{@name} #{equation_name_tail}"]
    end

    def duplicate(equation_name_tail)
      Equation.register(self.class.new(*duplication_params(equation_name_tail)))
    end

    def lateralized_duplicate(concrete_wheres, equation_name_tail)
      Equation.register(LateralizedEquation.new(concrete_wheres, *duplication_params(equation_name_tail)))
    end

    def update_attribute(attribute, value, prefix = nil)
      if @refinements
        attribute = "#{prefix}_#{attribute}" if prefix
        @refinements.each { |ref| ref.equation_instance.send("#{attribute}=", value) }
      else
        instance_variable_set("@#{attribute}".to_sym, value)
      end
    end

    def find_spec(used_atom_str, find_type: :any, &block)
      spec_name, atom_keyname = match_used_atom(used_atom_str)
      find_lambda = -> specs do
        result = specs.select { |spec| spec.name == spec_name }
        syntax_error('.cannot_be_mapped', name: spec_name) if result.size > 1
        result.first
      end

      if find_type == :any
        specific_spec = find_lambda[@source] || find_lambda[@products]
        syntax_error('matcher.undefined_used_atom', name: used_atom_str) unless specific_spec
        block[specific_spec, atom_keyname]
      elsif find_type == :all
        specific_specs = [find_lambda[@source], find_lambda[@products]].compact
        syntax_error('matcher.undefined_used_atom', name: used_atom_str) if specific_specs.empty?
        specific_specs.each { |ss| block[ss, atom_keyname] }
      else
        raise "Undefined find type #{find_type}"
      end
    end
  end

end
