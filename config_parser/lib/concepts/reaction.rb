module VersatileDiamond
  module Concepts

    # Also contained positions between the reactants
    # TODO: rspec
    class Reaction < UbiquitousReaction

      # Among super, keeps the atom map
      # @param [Array] source see at #super.initialize same argument
      # @param [Array] products see at #super.initialize same argument
      # @param [Array] atoms_map the atom-mapping result
      def initialize(name, source, products, atoms_map)
        super(name, source, products)
        @atoms_map = atoms_map
      end

      # Duplicates current instance with each source and product specs
      # @param [String] equation_name_tail the tail of equaion name
      # @return [Reaction] the duplicated reaction with changed name
      def duplicate(equation_name_tail)
        duplication = self.class.new(
          "#{@name} #{equation_name_tail}", *duplicate_params)
        duplication.positions = @positions.dup if @positions # TODO: rspec it
        duplication
      end

      # %w(incoherent unfixed).each do |state|
      #   define_method(state) do |*used_atom_strs|
      #     used_atom_strs.each do |atom_str|
      #       find_spec(atom_str, find_type: :all) do |specific_spec, atom_keyname|
      #         specific_spec.send(state, atom_keyname)
      #       end
      #     end
      #   end
      # end

      # def position(*used_atom_strs, **options)
      #   first_atom, second_atom = used_atom_strs.map do |atom_str|
      #     find_spec(atom_str) do |specific_spec, atom_keyname|
      #       specific_spec.spec[atom_keyname]
      #     end
      #   end

      #   @positions ||= []
      #   @positions << [first_atom, second_atom, Position[options]]
      # end

      # def lateral(env_name, **target_refs)
      #   @laterals ||= {}
      #   if @laterals[env_name]
      #     syntax_error('equation.lateral_already_connected')
      #   else
      #     environment = Environment[env_name]
      #     resolved_target_refs = target_refs.map do |target_alias, used_atom_str|
      #       unless environment.is_target?(target_alias)
      #         syntax_error('equation.undefined_target_alias', name: target_alias)
      #       end

      #       atom = find_spec(used_atom_str) do |specific_spec, atom_keyname|
      #         specific_spec.spec[atom_keyname]
      #       end
      #       [target_alias, atom]
      #     end

      #     @laterals[env_name] = Lateral.new(
      #       environment, Hash[resolved_target_refs])
      #   end
      # end

      # def there(*names)
      #   concrete_wheres = names.map do |name|
      #     laterals_with_where_hash = @laterals.select do |_, lateral|
      #       lateral.has_where?(name)
      #     end
      #     laterals_with_where = laterals_with_where_hash.values

      #     if laterals_with_where.size < 1
      #       syntax_error('where.undefined', name: name)
      #     elsif laterals_with_where.size > 1
      #       syntax_error('equation.multiple_wheres', name: name)
      #     end

      #     laterals_with_where.first.concretize_where(name)
      #   end

      #   name_tail = concrete_wheres.map(&:description).join(' and ')
      #   nest_refinement(lateralized_duplicate(concrete_wheres, name_tail))
      # end

      # def same?(other)
      #   is_same_positions = (!@positions && !other.positions) ||
      #     (@positions && other.positions &&
      #       lists_are_identical?(@positions, other.positions) do |pos1, pos2|
      #         pos1.last == pos2.last &&
      #           ((pos1[0] == pos2[0] && pos1[1] == pos2[1]) ||
      #             (pos1[0] == pos2[1] && pos1[1] == pos2[0]))
      #       end)

      #   is_same_positions && super
      # end

      # def simple_source
      #   @simple_source ||= @source.select do |specific_spec|
      #     specific_spec.simple?
      #   end
      # end

      # def complex_source
      #   @complex_source ||= @source - simple_source
      # end

      # def organize_dependencies(lateral_equations)
      #   applicants = []
      #   lateral_equations.each do |equation|
      #     applicants << equation if same?(equation)
      #   end

      #   return if applicants.empty?

      #   loop do
      #     inc = applicants.select do |equation|
      #       applicants.find do |uneq|
      #         equation != uneq && equation.dependent_from.include?(uneq)
      #       end
      #     end
      #     break if inc.empty?
      #     applicants = inc
      #   end

      #   applicants.each { |equation| dependent_from << equation }
      # end

    protected

      # attr_accessor :positions
      attr_writer :positions
      # attr_writer :refinements

      # def reverse
      #   super do |r|
      #     r.positions = @positions
      #     r.refinements = @refinements
      #   end
      # end

    private

      # def nest_refinement(equation)
      #   equation.parent = self
      #   equation.positions = @positions.dup if @positions

      #   @refinements ||= []
      #   @refinements << (refinement = Refinement.new(equation))
      #   nested(refinement)
      # end

      # Reverse params for creating reverse reaction with reversing of atom
      # mapping result
      #
      # @return [Array] reversed parameters for creating reverse reaction
      def reverse_params
        reversed_atom_map = @atoms_map.map do |specs, indexes|
          [specs.reverse, indexes.map { |pair| pair.reverse }]
        end
        [*super, reversed_atom_map]
      end

      # Duplicates internal properties of reaction such as specs and atom
      # mapping result
      #
      # @return [Array] the array of duplicated properties
      def duplicate_params
        # # TODO: костыль, because calling .reverse for parent in reverse method
        # name = @name
        # forward_regex = / forward\Z/
        # if instance_variable_get(:@reverse) && name =~ forward_regex
        #   name.sub!(forward_regex, '')
        # end

        hash = {}
        source_dup, products_dup = [@source, @products].map do |specs|
          specs.map do |spec|
            spec_dup = spec.dup
            hash[spec] = spec_dup
            spec_dup
          end
        end

        atoms_map = @atoms_map.map do |(source, product), indexes|
          [[hash[source], hash[product]], indexes]
        end

        [source_dup, products_dup, atoms_map]
      end

      # def lateralized_duplicate(concrete_wheres, equation_name_tail)
      #   Equation.register(
      #     LateralizedEquation.new(
      #       concrete_wheres, *duplicate_params(equation_name_tail)))
      # end

      # def find_spec(used_atom_str, find_type: :any, &block)
      #   spec_name, atom_keyname = match_used_atom(used_atom_str)
      #   find_lambda = -> specs do
      #     result = specs.select { |spec| spec.name == spec_name }
      #     syntax_error('.cannot_be_mapped', name: spec_name) if result.size > 1
      #     result.first
      #   end

      #   if find_type == :any
      #     specific_spec = find_lambda[@source] || find_lambda[@products]
      #     unless specific_spec
      #       syntax_error('matcher.undefined_used_atom', name: used_atom_str)
      #     end

      #     block[specific_spec, atom_keyname]
      #   elsif find_type == :all
      #     specific_specs = [find_lambda[@source], find_lambda[@products]].compact
      #     if specific_specs.empty?
      #       syntax_error('matcher.undefined_used_atom', name: used_atom_str)
      #     end

      #     specific_specs.each { |ss| block[ss, atom_keyname] }
      #   else
      #     raise "Undefined find type #{find_type}"
      #   end
      # end

      # def update_attribute(attribute, value, prefix = nil)
      #   if @refinements
      #     attribute = "#{prefix}_#{attribute}" if prefix
      #     @refinements.each do |ref|
      #       ref.equation_instance.send("#{attribute}=", value)
      #     end
      #   else
      #     super
      #   end
      # end

      # def accept_self(visitor)
      #   visitor.accept_real_equation(self)
      # end

      # def analyze_and_visit_source_specs(visitor)
      #   @source.each do |spec|
      #     spec.look_around(@atoms_map)
      #     spec.visit(visitor)
      #   end
      # end
    end

  end
end
