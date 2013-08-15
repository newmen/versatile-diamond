module VersatileDiamond
  module Interpreter

    # Interprets equation block if it exists. Pass each additional property to
    # reaction concept instance.
    class Equation < ComplexComponent
      include ReactionRefinements

      # Initialize a new equation interpreter instance
      # @param [Concepts::Reaction] reaction the concept of reaction
      # @param [Hash] names_and_specs the hash with :source and :products keys
      #   with arrays of names and specs as values
      def initialize(reaction, names_and_specs)
        @reaction, @names_and_specs = reaction, names_and_specs
      end

      # Interprets refinement line, duplicates reaction concept, pass it to
      # refinement interpreter instance and nest it instance
      #
      # @param [String] tail_of_name the tail of name of reaction concept
      def refinement(tail_of_name)
        names_and_specs = {}
        duplicate = @reaction.duplicate(tail_of_name) do |type, mirror|
          names_and_specs[type] = []
          @names_and_specs[type].each do |name, spec|
            names_and_specs[type] << [name, mirror[spec]]
          end
        end
        nest_refinement(duplicate, names_and_specs)
      end

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

      # Nests refinement setuped to duplicated reaction and stores it reaction
      # to chest
      #
      # @param [Concepts::Reaction] reaction_dup the duplicate of current
      #   reaction concept
      # @param [Hash] names_and_specs remaked for duplicated specs
      def nest_refinement(reaction_dup, names_and_specs)
        Tools::Chest.store(reaction_dup)
        nested(Refinement.new(reaction_dup, names_and_specs))
      end
    end

  end
end
