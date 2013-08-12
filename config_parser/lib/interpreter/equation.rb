module VersatileDiamond
  module Interpreter

    # Interprets equation block if it exists. Pass each additional property to
    # reaction concept instance.
    class Equation < ComplexComponent
      # include AtomMatcher

      def initialize(concept, names_and_specs)
        @concept, @names_and_specs = concept, names_and_specs
      end

      # def refinement(name)
      #   nest_refinement(duplicate(name))
      # end

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

    protected

    private

      # def nest_refinement(equation)
      #   equation.parent = self
      #   equation.positions = @positions.dup if @positions

      #   @refinements ||= []
      #   @refinements << (refinement = Refinement.new(equation))
      #   nested(refinement)
      # end

      # def reverse_params
      #   reversed_atom_map = @atoms_map.map do |specs, indexes|
      #     [specs.reverse, indexes.map { |pair| pair.reverse }]
      #   end
      #   [*super, reversed_atom_map]
      # end

      # def duplication_params(equation_name_tail)
      #   # TODO: костыль, because calling .reverse for parent in reverse method
      #   name = @name
      #   forward_regex = / forward\Z/
      #   if instance_variable_get(:@reverse) && name =~ forward_regex
      #     name.sub!(forward_regex, '')
      #   end

      #   hash = {}
      #   source_dup, products_dup = [@source, @products].map do |specs|
      #     specs_dup = specs.map do |spec|
      #       spec_dup = spec.dup
      #       hash[spec] = spec_dup
      #       spec_dup
      #     end
      #     specs_dup
      #   end

      #   atoms_map = @atoms_map.map do |(source, product), indexes|
      #     [[hash[source], hash[product]], indexes]
      #   end

      #   ["#{name} #{equation_name_tail}",
      #     source_dup, products_dup, atoms_map]
      # end

      # def duplicate(equation_name_tail)
      #   Equation.register(
      #     self.class.new(*duplication_params(equation_name_tail)))
      # end

      # def lateralized_duplicate(concrete_wheres, equation_name_tail)
      #   Equation.register(
      #     LateralizedEquation.new(
      #       concrete_wheres, *duplication_params(equation_name_tail)))
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
    end

  end
end
