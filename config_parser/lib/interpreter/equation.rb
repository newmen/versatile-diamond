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
      # @param [String] the tail of name of reaction concept
      # @param [Array] dup_args arguments which will be passed to duplicate
      #   method
      # @option [Symbol] :method the method which will be called for create
      #   duplicate reaction
      def refinement(*dup_args, method: :duplicate)
        names_and_specs = {}
        dup = @reaction.send(method, *dup_args) do |type, mirror|
          names_and_specs[type] = []
          @names_and_specs[type].each do |name, spec|
            names_and_specs[type] << [name, mirror[spec]]
          end
        end
        nest_refinement(dup, names_and_specs)
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
        resolved_targets = target_refs.map do |target_name, used_atom_str|
          unless env.is_target?(target_name)
            syntax_error('.undefined_target', name: target_name)
          end

          atom = find_spec(used_atom_str) do |specific_spec, keyname|
            specific_spec.atom(keyname)
          end
          [target_name, atom]
        end

        lateral = env.make_lateral(Hash[resolved_targets])
        store(@reaction, lateral)
      rescue Concepts::Environment::InvalidTarget => e
        syntax_error('.undefined_target', name: e.target)
      end

      # Interprets there line and nest new refinement
      # @param [Array] names the array of names of used wheres
      # @raise [KeyNameError] if where cannot be found or has many wheres with
      #   similar names for instance there object
      def there(*names)
        theres = names.map { |name| get(:there, @reaction, name) }
        name_tail = theres.map(&:description).join(' and ')
        refinement(name_tail, theres, method: :lateral_duplicate)
      end

    private

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
