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
      # @param [String] name_tail the tail of name of reaction concept
      def refinement(name_tail)
        dup_and_nest(@reaction, :duplicate, name_tail)
      end

      # Interprets lateral line, stores used environment and setup target atoms
      # for it as lateral object
      #
      # @param [Symbol] env_name the name of used environment
      # @param [Hash] target_refs the hash of references where keys is names of
      #   targets from equation and values is used atoms from reaction concept
      # @rescue [Errors::SyntaxError] if wrong target setup or if environment
      #   cannot be resolved, or lateral already connected for current reaction
      def lateral(env_name, **target_refs)
        env = get(:environment, env_name)
        targeted = {}
        resolved_targets = target_refs.map do |target_name, used_atom_str|
          if env.target?(target_name) && !targeted[target_name]
            targeted[target_name] = true
          else
            syntax_error('.undefined_target', name: target_name)
          end

          specific_spec, keyname = find_any_spec(used_atom_str)
          [target_name, [specific_spec, specific_spec.atom(keyname)]]
        end

        lateral = env.make_lateral(Hash[resolved_targets])
        store(@reaction, lateral)
      end

      # Interprets there line and nest new refinement
      # @param [Array] names the array of names of used wheres
      # @raise [KeyNameError] if where cannot be found or has many wheres with
      #   similar names for instance there object
      def there(*names)
        theres = names.map { |name| get(:there, @reaction, name) }
        name_tail = theres.map(&:description).join(' and ')
        specs = theres.map(&:target_specs).reduce(:+)
        reaction = current_reaction(*specs)

        dup_and_nest(reaction, :lateral_duplicate, name_tail, theres)
      end

    private

      # Duplicates passed reaction by method with concrete arguments
      # @param [Reaction] reaction the reaction which will be duplicated
      # @param [Symbol] method the method for duplicating
      # @param [Array] dup_args the arguments which will be passed to duplicate
      #   method
      def dup_and_nest(reaction, method, *dup_args)
        names_and_specs = {}
        is_forward = reaction.type == :forward
        dup = reaction.send(method, *dup_args) do |type, mirror|
          type = type == :source ?
            (is_forward ? :source : :products) :
            (is_forward ? :products : :source)

          names_and_specs[type] = []
          @names_and_specs[type].each do |name, spec|
            names_and_specs[type] << [name, mirror[spec]]
          end
        end

        nest_refinement(dup.as(:forward), names_and_specs)
      end

      # Nests refinement setuped to duplicated reaction and stores it reaction
      # to chest
      #
      # @param [Concepts::Reaction] reaction_dup the duplicate of current
      #   reaction concept
      # @param [Hash] names_and_specs remaked for duplicated specs
      def nest_refinement(reaction_dup, names_and_specs)
        store(reaction_dup)
        nested(Refinement.new(reaction_dup, names_and_specs))
      end
    end

  end
end
