module VersatileDiamond

  class Equation < UbiquitousEquation
    include AtomMatcher

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

        if has_termination_spec(source, products)
          UbiquitousEquation.new(name, source, products)
        else
          atoms_map = AtomMapper.map(source, products)
          new(name, source, products, atoms_map)
        end
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
        combinations = specs.size.times.reduce([]) do |acc, i|
          acc + specs.combination(i + 1).to_a
        end

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

            args = type == :source ?
              [duplicate_specs, products] :
              [source, duplicate_specs]

            result = check_balance(*args, deep - 1, &block)
            if result then return result else next end
          end
        end
        false
      end

      # TODO: if checks every possible extending way for complete condition
      # then analyzer may accept incorrect equation
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
          product = products.find { |spec| spec.name == group.first.name }
          if group.size > 1 && product
            syntax_error('.cannot_be_mapped', name: group.first.name)
          end
        end

        check_compliance(products, source, deep - 1) if deep > 0
      end

      def has_termination_spec(source, products)
        check = -> specific_spec { specific_spec.is_a?(TerminationSpec) }
        source.find(&check) || products.find(&check)
      end
    end

    def initialize(name, source_specs, products_specs, atoms_map)
      super(name, source_specs, products_specs)
      @atoms_map = atoms_map
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
        find_spec(atom_str) do |specific_spec, atom_keyname|
          specific_spec.spec[atom_keyname]
        end
      end

      @positions ||= []
      @positions << [first_atom, second_atom, Position[options]]
    end

    def lateral(env_name, **target_refs)
      @laterals ||= {}
      if @laterals[env_name]
        syntax_error('equation.lateral_already_connected')
      else
        environment = Environment[env_name]
        resolved_target_refs = target_refs.map do |target_alias, used_atom_str|
          unless environment.is_target?(target_alias)
            syntax_error('equation.undefined_target_alias', name: target_alias)
          end

          atom = find_spec(used_atom_str) do |specific_spec, atom_keyname|
            specific_spec.spec[atom_keyname]
          end
          [target_alias, atom]
        end

        @laterals[env_name] = Lateral.new(
          environment, Hash[resolved_target_refs])
      end
    end

    def there(*names)
      concrete_wheres = names.map do |name|
        laterals_with_where_hash = @laterals.select do |_, lateral|
          lateral.has_where?(name)
        end
        laterals_with_where = laterals_with_where_hash.values

        if laterals_with_where.size < 1
          syntax_error('where.undefined', name: name)
        elsif laterals_with_where.size > 1
          syntax_error('equation.multiple_wheres', name: name)
        end

        laterals_with_where.first.concretize_where(name)
      end

      name_tail = concrete_wheres.map(&:description).join(' and ')
      nest_refinement(lateralized_duplicate(concrete_wheres, name_tail))
    end

    def same?(other)
      is_same_positions = (!@positions && !other.positions) ||
        (@positions && other.positions &&
          lists_are_identical?(@positions, other.positions) do |pos1, pos2|
            pos1.last == pos2.last &&
              ((pos1[0] == pos2[0] && pos1[1] == pos2[1]) ||
                (pos1[0] == pos2[1] && pos1[1] == pos2[0]))
          end)

      is_same_positions && super
    end

    def simple_source
      @simple_source ||= @source.select do |specific_spec|
        specific_spec.simple?
      end
    end

    def complex_source
      @complex_source ||= @source - simple_source
    end

    def organize_dependencies(lateral_equations)
      applicants = []
      lateral_equations.each do |equation|
        applicants << equation if same?(equation)
      end

      return if applicants.empty?

      loop do
        inc = applicants.select do |equation|
          applicants.find do |uneq|
            equation != uneq && equation.dependent_from.include?(uneq)
          end
        end
        break if inc.empty?
        applicants = inc
      end

      applicants.each { |equation| dependent_from << equation }
    end

  protected

    attr_accessor :positions
    attr_writer :refinements

    def reverse
      super do |r|
        r.positions = @positions
        r.refinements = @refinements
      end
    end

  private

    def nest_refinement(equation)
      equation.parent = self
      equation.positions = @positions.dup if @positions

      @refinements ||= []
      @refinements << (refinement = Refinement.new(equation))
      nested(refinement)
    end

    def reverse_params
      [*super, @atoms_map]
    end

    def duplication_params(equation_name_tail)
      # TODO: костыль, because calling .reverse for parent in reverse method
      name = @name
      forward_regex = / forward\Z/
      if instance_variable_get(:@reverse) && name =~ forward_regex
        name.sub!(forward_regex, '')
      end

      ["#{name} #{equation_name_tail}",
        @source.map(&:dup), @products.map(&:dup), @atoms_map]
    end

    def duplicate(equation_name_tail)
      Equation.register(
        self.class.new(*duplication_params(equation_name_tail)))
    end

    def lateralized_duplicate(concrete_wheres, equation_name_tail)
      Equation.register(
        LateralizedEquation.new(
          concrete_wheres, *duplication_params(equation_name_tail)))
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
        unless specific_spec
          syntax_error('matcher.undefined_used_atom', name: used_atom_str)
        end

        block[specific_spec, atom_keyname]
      elsif find_type == :all
        specific_specs = [find_lambda[@source], find_lambda[@products]].compact
        if specific_specs.empty?
          syntax_error('matcher.undefined_used_atom', name: used_atom_str)
        end

        specific_specs.each { |ss| block[ss, atom_keyname] }
      else
        raise "Undefined find type #{find_type}"
      end
    end

    def update_attribute(attribute, value, prefix = nil)
      if @refinements
        attribute = "#{prefix}_#{attribute}" if prefix
        @refinements.each do |ref|
          ref.equation_instance.send("#{attribute}=", value)
        end
      else
        super
      end
    end

    def accept_self(visitor)
      visitor.accept_real_equation(self)
    end
  end

end
